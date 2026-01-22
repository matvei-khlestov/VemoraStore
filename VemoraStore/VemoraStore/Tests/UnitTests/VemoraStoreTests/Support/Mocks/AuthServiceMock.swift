//
//  AuthServiceMock.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.10.2025.
//

import Foundation
import Combine
@testable import VemoraStore

final class AuthServiceMock: AuthServiceProtocol {

    // MARK: - Config

    var signInResult: Result<Void, Error> = .success(())
    var signUpResult: Result<Void, Error> = .success(())
    var signOutResult: Result<Void, Error> = .success(())
    var deleteResult: Result<Void, Error> = .success(())

    var updateEmailResult: Result<Void, Error> = .success(())

    /// Какой UID выставлять после успешного signIn/signUp (можно менять в тесте)
    var uidOnSignIn: String? = "mock_uid"
    var uidOnSignUp: String? = "mock_uid"

    // MARK: - State

    var currentUserId: String? = nil {
        didSet { isAuthorizedSubject.send(currentUserId != nil) }
    }

    // MARK: - Tracking

    private(set) var signInCalls = 0
    private(set) var lastSignInEmail: String?
    private(set) var lastSignInPassword: String?

    private(set) var signUpCalls = 0
    private(set) var lastSignUpEmail: String?
    private(set) var lastSignUpPassword: String?

    private(set) var updateEmailCalls = 0
    private(set) var lastUpdateEmailNewEmail: String?
    private(set) var lastUpdateEmailCurrentPassword: String?

    // MARK: - Publisher

    private let isAuthorizedSubject = CurrentValueSubject<Bool, Never>(false)
    var isAuthorizedPublisher: AnyPublisher<Bool, Never> {
        isAuthorizedSubject.eraseToAnyPublisher()
    }

    // MARK: - API

    func signIn(email: String, password: String) async throws {
        signInCalls += 1
        lastSignInEmail = email
        lastSignInPassword = password
        switch signInResult {
        case .success:
            currentUserId = uidOnSignIn
        case .failure(let error):
            throw error
        }
    }

    func signUp(email: String, password: String) async throws {
        signUpCalls += 1
        lastSignUpEmail = email
        lastSignUpPassword = password
        switch signUpResult {
        case .success:
            currentUserId = uidOnSignUp
        case .failure(let error):
            throw error
        }
    }

    func signOut() async throws {
        switch signOutResult {
        case .success: currentUserId = nil
        case .failure(let error): throw error
        }
    }

    func deleteAccount() async throws {
        switch deleteResult {
        case .success: currentUserId = nil
        case .failure(let error): throw error
        }
    }

    func updateEmail(to newEmail: String, currentPassword: String) async throws {
        updateEmailCalls += 1
        lastUpdateEmailNewEmail = newEmail
        lastUpdateEmailCurrentPassword = currentPassword

        switch updateEmailResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
}

