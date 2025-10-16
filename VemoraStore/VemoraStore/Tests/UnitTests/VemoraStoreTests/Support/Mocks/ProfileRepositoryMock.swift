//
//  ProfileRepositoryMock.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import Foundation
import Combine
@testable import VemoraStore

final class ProfileRepositoryMock: ProfileRepository {
    
    // MARK: Tracking
    
    private(set) var ensureCalls = 0
    private(set) var lastEnsureArgs: (uid: String, name: String, email: String)?
    private(set) var refreshCalls = 0
    private(set) var updateNameCalls = 0
    private(set) var updateEmailCalls = 0
    private(set) var updatePhoneCalls = 0

    // MARK: Configurable results
    
    var ensureResult: Result<Void, Error> = .success(())
    var refreshResult: Result<Void, Error> = .success(())
    var updateNameResult: Result<Void, Error> = .success(())
    var updateEmailResult: Result<Void, Error> = .success(())
    var updatePhoneResult: Result<Void, Error> = .success(())

    // MARK: Stubbed publisher
    
    private let subject = CurrentValueSubject<UserProfile?, Never>(nil)

    func observeProfile() -> AnyPublisher<UserProfile?, Never> {
        subject.eraseToAnyPublisher()
    }

    func refresh(uid: String) async throws {
        refreshCalls += 1
        switch refreshResult {
        case .success: return
        case .failure(let e): throw e
        }
    }

    func ensureInitialProfile(uid: String, name: String, email: String) async throws {
        ensureCalls += 1
        lastEnsureArgs = (uid, name, email)
        switch ensureResult {
        case .success: return
        case .failure(let e): throw e
        }
    }

    func updateName(uid: String, name: String) async throws {
        updateNameCalls += 1
        switch updateNameResult {
        case .success: return
        case .failure(let e): throw e
        }
    }

    func updateEmail(uid: String, email: String) async throws {
        updateEmailCalls += 1
        switch updateEmailResult {
        case .success: return
        case .failure(let e): throw e
        }
    }

    func updatePhone(uid: String, phone: String) async throws {
        updatePhoneCalls += 1
        switch updatePhoneResult {
        case .success: return
        case .failure(let e): throw e
        }
    }
}
