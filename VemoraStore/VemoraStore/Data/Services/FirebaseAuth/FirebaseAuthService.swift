//
//  FirebaseAuthService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine
import FirebaseAuth

/// Сервис аутентификации `FirebaseAuthService`
///
/// Реализация `AuthServiceProtocol` поверх Firebase Authentication (email/password).
///
/// Обеспечивает:
/// - управление жизненным циклом сессии (вход/регистрация/выход/удаление аккаунта);
/// - реактивный статус авторизации через Combine (`isAuthorizedPublisher`);
/// - синхронизацию локальной сессии (`AuthSessionStoringProtocol`) с реальным состоянием FirebaseAuth;
/// - смену e-mail через flow Firebase с подтверждением по письму
///   (`sendEmailVerification(beforeUpdatingEmail:)`) и предварительной реаутентификацией.
///
/// ### Особенности смены e-mail
/// В актуальных версиях Firebase прямой `updateEmail` может быть ограничен.
/// Рекомендуемый сценарий:
/// 1) `reload()` текущего пользователя;
/// 2) `reauthenticate(...)` с текущим email и паролем;
/// 3) `sendEmailVerification(beforeUpdatingEmail:)` — отправка письма на новый email.
/// Смена адреса завершится только после подтверждения по ссылке.
///
/// ### Потоки и состояние
/// - `isAuthorizedPublisher` эмитит `true/false` при смене пользователя в Firebase.
/// - `currentUserId` хранит текущий UID (или `nil`).
///
/// ### Навигационная интеграция
/// `Auth.addStateDidChangeListener` устанавливается при инициализации и снимается в `deinit`.

final class FirebaseAuthService: AuthServiceProtocol {
    
    // MARK: - Publishers
    
    /// Внутренний subject со статусом авторизации.
    private let isAuthorizedSubject = CurrentValueSubject<Bool, Never>(false)
    
    /// Паблишер, отражающий текущий статус авторизации (`true` — пользователь вошёл).
    var isAuthorizedPublisher: AnyPublisher<Bool, Never> {
        isAuthorizedSubject.eraseToAnyPublisher()
    }
    
    // MARK: - State
    
    /// Текущий UID пользователя (если авторизован).
    private(set) var currentUserId: String? = nil
    
    /// Хэндл листенера FirebaseAuth.
    private var authListener: AuthStateDidChangeListenerHandle?
    
    // MARK: - Deps
    
    /// Хранилище сессии (Keychain/UserDefaults и т.п.).
    private let session: AuthSessionStoringProtocol
    
    // MARK: - Init
    
    /// Инициализация сервиса с внешним хранилищем сессии.
    /// - Parameter session: Реализация хранения сессии.
    init(session: AuthSessionStoringProtocol) {
        self.session = session
        setupAuthListener()
        syncInitialAuthState()
    }
    
    /// Снятие слушателей при деинициализации.
    deinit {
        removeAuthListenerIfNeeded()
    }
    
    // MARK: - API
    
    /// Вход по email и паролю.
    /// - Parameters:
    ///   - email: Электронная почта.
    ///   - password: Пароль.
    /// - Throws: Доменные ошибки авторизации, см. `mapFirebaseAuthError(_:)`.
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            applyAuthState(result.user)
        } catch {
            throw mapFirebaseAuthError(error)
        }
    }
    
    /// Регистрация нового пользователя по email и паролю.
    /// - Parameters:
    ///   - email: Электронная почта.
    ///   - password: Пароль.
    /// - Throws: Доменные ошибки регистрации, см. `mapFirebaseAuthError(_:)`.
    func signUp(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            applyAuthState(result.user)
        } catch {
            throw mapFirebaseAuthError(error)
        }
    }
    
    /// Выход из учётной записи.
    /// - Throws: Ошибка выхода, см. `mapFirebaseAuthError(_:)`.
    func signOut() async throws {
        do {
            try Auth.auth().signOut()
            applyAuthState(nil)
        } catch {
            throw mapFirebaseAuthError(error)
        }
    }
    
    /// Удаление текущей учётной записи пользователя.
    /// - Throws: Ошибка удаления, см. `mapFirebaseAuthError(_:)`.
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { return }
        do {
            try await user.delete()
            applyAuthState(nil)
        } catch {
            throw mapFirebaseAuthError(error)
        }
    }
    
    /// Инициирует смену e-mail аккаунта с подтверждением по письму.
    ///
    /// Алгоритм:
    /// 1) обновляет данные пользователя `reload()` (важно для актуального email/токенов);
    /// 2) выполняет `reauthenticate(...)` текущим email и паролем;
    /// 3) отправляет письмо подтверждения на новый email (`sendEmailVerification(beforeUpdatingEmail:)`).
    ///
    /// - Parameters:
    ///   - newEmail: Новый e-mail.
    ///   - currentPassword: Текущий пароль пользователя.
    /// - Throws: Доменные ошибки смены e-mail/реаутентификации, см. `mapFirebaseAuthError(_:)`.
    func updateEmail(to newEmail: String, currentPassword: String) async throws {
        guard let user = Auth.auth().currentUser else { return }
        
        let password = currentPassword.trimmingCharacters(in: .whitespacesAndNewlines)
        if password.isEmpty { throw AuthDomainError.invalidCredentials }
        
        do {
            try await user.reload()
            
            let currentEmail = user.email ?? ""
            if currentEmail.isEmpty { throw AuthDomainError.unknown }
            
            try await reauthenticate(email: currentEmail, password: password)
            try await user.sendEmailVerification(beforeUpdatingEmail: newEmail)
            
        } catch {
            throw mapFirebaseAuthError(error)
        }
    }
}

// MARK: - Private: Listener & State syncing

private extension FirebaseAuthService {
    
    /// Подписка на изменения состояния FirebaseAuth.
    func setupAuthListener() {
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.applyAuthState(user)
        }
    }
    
    /// Удаление listener, если он установлен.
    func removeAuthListenerIfNeeded() {
        if let h = authListener {
            Auth.auth().removeStateDidChangeListener(h)
        }
        authListener = nil
    }
    
    /// Синхронизация локального состояния с Firebase при старте.
    func syncInitialAuthState() {
        applyAuthState(Auth.auth().currentUser)
    }
    
    /// Применение нового состояния аутентификации (обновляет UID, паблишер и сессию).
    func applyAuthState(_ user: User?) {
        currentUserId = user?.uid
        let isAuth = (user != nil)
        isAuthorizedSubject.send(isAuth)
        
        if let uid = user?.uid {
            session.saveSession(userId: uid, provider: "email")
        } else {
            session.clearSession()
        }
    }
    
    /// Реаутентификация пользователя по email/password.
    ///
    /// Используется для операций, требующих “recent login” (например, смена e-mail).
    /// - Parameters:
    ///   - email: Текущий e-mail пользователя.
    ///   - password: Текущий пароль пользователя.
    func reauthenticate(email: String, password: String) async throws {
        guard let user = Auth.auth().currentUser else { return }
        
        guard user.providerData.contains(where: { $0.providerID == "password" }) else {
            throw AuthDomainError.unknown
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        _ = try await user.reauthenticate(with: credential)
    }
}

// MARK: - Error mapping

private extension FirebaseAuthService {
    
    /// Доменные ошибки авторизации для пользовательских сообщений.
    enum AuthDomainError: LocalizedError {
        /// Неверные учётные данные.
        case invalidCredentials
        /// Учётная запись отключена.
        case userDisabled
        /// Email уже используется.
        case emailAlreadyInUse
        /// Слишком слабый пароль.
        case weakPassword
        /// Слишком много попыток.
        case tooManyRequests
        /// Проблемы с сетью.
        case network
        /// Требуется повторный вход.
        case requiresRecentLogin
        /// Смена e-mail требует подтверждения по письму.
        case emailChangeRequiresVerification
        /// Неизвестная ошибка.
        case unknown
        
        /// Локализованное описание ошибки.
        var errorDescription: String? {
            switch self {
            case .invalidCredentials:
                return "Неверный email или пароль."
            case .userDisabled:
                return "Учётная запись отключена."
            case .emailAlreadyInUse:
                return "Email уже используется."
            case .weakPassword:
                return "Слишком простой пароль."
            case .tooManyRequests:
                return "Слишком много попыток. Попробуйте позже."
            case .network:
                return "Проблема с сетью."
            case .requiresRecentLogin:
                return "Для операции нужно войти заново."
            case .emailChangeRequiresVerification:
                return "На новый e-mail отправлено письмо. Подтвердите адрес по ссылке, затем e-mail сменится."
            case .unknown:
                return "Неизвестная ошибка."
            }
        }
    }
    
    /// Преобразование ошибок FirebaseAuth в доменные ошибки.
    func mapFirebaseAuthError(_ error: Error) -> Error {
        let ns = error as NSError
        guard ns.domain == AuthErrorDomain,
              let code = AuthErrorCode(rawValue: ns.code)
        else { return AuthDomainError.unknown }
        
        switch code {
        case .wrongPassword, .userNotFound, .invalidEmail, .invalidCredential:
            return AuthDomainError.invalidCredentials
            
        case .userDisabled:
            return AuthDomainError.userDisabled
            
        case .emailAlreadyInUse:
            return AuthDomainError.emailAlreadyInUse
            
        case .weakPassword:
            return AuthDomainError.weakPassword
            
        case .tooManyRequests:
            return AuthDomainError.tooManyRequests
            
        case .networkError:
            return AuthDomainError.network
            
        case .requiresRecentLogin, .userTokenExpired, .invalidUserToken:
            return AuthDomainError.requiresRecentLogin
            
        case .operationNotAllowed:
            return AuthDomainError.emailChangeRequiresVerification
            
        default:
            return AuthDomainError.unknown
        }
    }
}
