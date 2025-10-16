//
//  ProfileRepositorySpy_EditPhone.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import Foundation
import Combine
@testable import VemoraStore

/// Узкоспециализированный spy под EditPhoneViewModel
final class ProfileRepositorySpy_EditPhone: ProfileRepository {
    
    private let subject = CurrentValueSubject<UserProfile?, Never>(nil)
    func observeProfile() -> AnyPublisher<UserProfile?, Never> { subject.eraseToAnyPublisher() }
    func send(_ profile: UserProfile?) { subject.send(profile) }
    
    private(set) var updatePhoneCalls = 0
    private(set) var lastUpdatePhone: (uid: String, phone: String)?
    
    func refresh(uid: String) async throws {}
    func ensureInitialProfile(uid: String, name: String, email: String) async throws {}
    func updateName(uid: String, name: String) async throws {}
    func updateEmail(uid: String, email: String) async throws {}
    
    func updatePhone(uid: String, phone: String) async throws {
        updatePhoneCalls += 1
        lastUpdatePhone = (uid, phone)
    }
}
