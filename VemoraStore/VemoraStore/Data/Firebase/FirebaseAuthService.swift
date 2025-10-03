//
//  FirebaseAuthService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine
import FirebaseAuth

final class FirebaseAuthService: AuthServiceProtocol {
    
    // MARK: - Publishers
    
    private let isAuthorizedSubject = CurrentValueSubject<Bool, Never>(false)
    var isAuthorizedPublisher: AnyPublisher<Bool, Never> {
        isAuthorizedSubject.eraseToAnyPublisher()
    }
    
    // MARK: - State
    
    private(set) var currentUserId: String? = nil
    private var authListener: AuthStateDidChangeListenerHandle?
    
    // MARK: - Deps
    
    private let session: AuthSessionStoringProtocol
    
    // MARK: - Init
    
    init(session: AuthSessionStoringProtocol) {
        self.session = session
        
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            self.currentUserId = user?.uid
            self.isAuthorizedSubject.send(user != nil)
            
            if let uid = user?.uid {
                self.session.saveSession(userId: uid, provider: "email")
            } else {
                self.session.clearSession()
            }
        }
        
        // Инициализация текущим состоянием
        let user = Auth.auth().currentUser
        currentUserId = user?.uid
        isAuthorizedSubject.send(user != nil)
        if let uid = user?.uid {
            session.saveSession(userId: uid, provider: "email")
        } else {
            session.clearSession()
        }
    }
    
    deinit {
        if let h = authListener { Auth.auth().removeStateDidChangeListener(h) }
    }
    
    // MARK: - API
    
    func signIn(email: String, password: String) async throws {
        do { _ = try await Auth.auth().signIn(withEmail: email, password: password) }
        catch { throw mapFirebaseAuthError(error) }
    }
    
    func signUp(email: String, password: String) async throws {
        do { _ = try await Auth.auth().createUser(withEmail: email, password: password) }
        catch { throw mapFirebaseAuthError(error) }
    }
    
    func signOut() async throws {
        do { try Auth.auth().signOut() }
        catch { throw mapFirebaseAuthError(error) }
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { return }
        do { try await user.delete() }
        catch { throw mapFirebaseAuthError(error) }
    }
}

// MARK: - Error mapping

private extension FirebaseAuthService {
    enum AuthDomainError: LocalizedError {
        case invalidCredentials
        case userDisabled
        case emailAlreadyInUse
        case weakPassword
        case tooManyRequests
        case network
        case unknown
        
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
            case .unknown:
                return "Неизвестная ошибка."
            }
        }
    }
    
    func mapFirebaseAuthError(_ error: Error) -> Error {
        let ns = error as NSError
        guard ns.domain == AuthErrorDomain,
              let code = AuthErrorCode(rawValue: ns.code)
                
        else {
            return AuthDomainError.unknown
        }
        
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
        default:
            return AuthDomainError.unknown
        }
    }
}
