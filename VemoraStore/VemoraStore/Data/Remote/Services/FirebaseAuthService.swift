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
/// — реализация `AuthServiceProtocol` поверх FirebaseAuth (email/password).
///
/// Назначение:
/// - управление жизненным циклом авторизации: `signIn`, `signUp`, `signOut`, `deleteAccount`;
/// - поддержание реактивного статуса входа через Combine (`isAuthorizedPublisher`);
/// - синхронизация локальной сессии (`AuthSessionStoringProtocol`) с фактическим состоянием Firebase;
/// - сопоставление ошибок FirebaseAuth в человекочитаемые доменные ошибки.
///
/// Зависимости:
/// - `FirebaseAuth` — провайдер аутентификации;
/// - `AuthSessionStoringProtocol` — хранилище сессии (Keychain/Defaults).
///
/// Состояние/выходы:
/// - `currentUserId` — актуальный UID авторизованного пользователя (или `nil`);
/// - `isAuthorizedPublisher` — паблишер булевого состояния (`true`, если пользователь вошёл).
///
/// Поведение:
/// - при инициализации настраивает `Auth.addStateDidChangeListener`, чтобы реагировать на смену
///   пользователя и рассылать обновления (`applyAuthState`);
/// - при входе/регистрации/выходе/удалении аккаунта обновляет `currentUserId`,
///   публикует `isAuthorized` и записывает/очищает сессию в `AuthSessionStoringProtocol`;
/// - использует `async/await` API FirebaseAuth, ошибки маппит в `AuthDomainError`
///   (например: `invalidCredentials`, `emailAlreadyInUse`, `weakPassword`, `requiresRecentLogin`).
///
/// Особенности:
/// - listener корректно снимается в `deinit`;
/// - `signOut()` и `deleteAccount()` приводят к очистке локальной сессии;
/// - коды ошибок FirebaseAuth (`AuthErrorCode`) транслируются в локализуемые описания для UI.

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
    init(session: AuthSessionStoringProtocol) {
        self.session = session
        setupAuthListener()
        syncInitialAuthState()
    }

    /// Очистка слушателей при деинициализации.
    deinit {
        removeAuthListenerIfNeeded()
    }

    // MARK: - API
    
    /// Вход по email и паролю.
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            applyAuthState(result.user)
        } catch {
            throw mapFirebaseAuthError(error)
        }
    }

    /// Регистрация нового пользователя по email и паролю.
    func signUp(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            applyAuthState(result.user)
        } catch {
            throw mapFirebaseAuthError(error)
        }
    }

    /// Выход из учётной записи.
    func signOut() async throws {
        do {
            try Auth.auth().signOut()
            applyAuthState(nil)
        } catch {
            throw mapFirebaseAuthError(error)
        }
    }

    /// Удаление учётной записи.
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { return }
        do {
            try await user.delete()
            applyAuthState(nil)
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
                return "Для удаления аккаунта нужно войти заново."
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
        case .wrongPassword, .invalidEmail, .userNotFound:
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
        default:
            return AuthDomainError.unknown
        }
    }
}
