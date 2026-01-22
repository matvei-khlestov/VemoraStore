//
//  ProfileRepositorySpy_EditEmail.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import Foundation
import Combine
@testable import VemoraStore

/// Узкоспециализированный spy под EditEmailViewModel
final class ProfileRepositorySpy_EditEmail: ProfileRepository {
    
    var updateEmailResult: Result<Void, Error> = .success(())
    
    private let subject = CurrentValueSubject<UserProfile?, Never>(nil)
    func observeProfile() -> AnyPublisher<UserProfile?, Never> { subject.eraseToAnyPublisher() }
    func send(_ profile: UserProfile?) { subject.send(profile) }
    
    private(set) var updateEmailCalls = 0
    private(set) var lastUpdateEmail: (uid: String, email: String)?
    
    func refresh(uid: String) async throws {}
    func ensureInitialProfile(uid: String, name: String, email: String) async throws {}
    func updateName(uid: String, name: String) async throws {}
    func updatePhone(uid: String, phone: String) async throws {}
    
    func updateEmail(uid: String, email: String) async throws {
        updateEmailCalls += 1
        lastUpdateEmail = (uid, email)
        
        switch updateEmailResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
}
