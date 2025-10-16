//
//  ProfileRepositorySpy_EditName.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import Foundation
import Combine
@testable import VemoraStore

/// Узкоспециализированный spy под EditNameViewModel (минимум API)
final class ProfileRepositorySpy_EditName: ProfileRepository {
    // Publisher
    private let subject = CurrentValueSubject<UserProfile?, Never>(nil)
    func observeProfile() -> AnyPublisher<UserProfile?, Never> { subject.eraseToAnyPublisher() }
    func send(_ profile: UserProfile?) { subject.send(profile) }

    // Tracking для updateName
    private(set) var updateNameCalls = 0
    private(set) var lastUpdateName: (uid: String, name: String)?

    // Ненужные для этих тестов методы — пустые заглушки
    func refresh(uid: String) async throws { }
    func ensureInitialProfile(uid: String, name: String, email: String) async throws { }
    func updateEmail(uid: String, email: String) async throws { }
    func updatePhone(uid: String, phone: String) async throws { }

    // Цель тестов
    func updateName(uid: String, name: String) async throws {
        updateNameCalls += 1
        lastUpdateName = (uid, name)
    }
}
