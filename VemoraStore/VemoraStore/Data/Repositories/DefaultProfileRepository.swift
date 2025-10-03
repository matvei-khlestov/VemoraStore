//
//  DefaultProfileRepository.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import Foundation
import Combine

final class DefaultProfileRepository: ProfileRepository {

    private let remote: ProfileCollectingProtocol
    private let local: LocalStore
    private let userId: String

    private var bag = Set<AnyCancellable>()

    private let subject = CurrentValueSubject<UserProfile?, Never>(nil)

    init(remote: ProfileCollectingProtocol, local: LocalStore, userId: String) {
        self.remote = remote
        self.local = local
        self.userId = userId

        local.observeProfile(userId: userId)
            .subscribe(subject)
            .store(in: &bag)
    }

    func observeProfile() -> AnyPublisher<UserProfile?, Never> {
        subject.eraseToAnyPublisher()
    }

    func refresh(uid: String) async throws {
        if let dto = try await remote.fetchProfile(uid: uid) {
            local.upsertProfile(dto)
        } else {
            // если профиля нет — можно создать пустой или оставить nil
        }
    }

    func ensureInitialProfile(uid: String, name: String, email: String) async throws {
        try await remote.ensureInitialUserProfile(uid: uid, name: name, email: email)
        try await refresh(uid: uid)
    }

    func updateName(uid: String, name: String) async throws {
        try await remote.updateName(uid: uid, name: name)
        try await refresh(uid: uid)
    }

    func updateEmail(uid: String, email: String) async throws {
        try await remote.updateEmail(uid: uid, email: email)
        try await refresh(uid: uid)
    }

    func updatePhone(uid: String, phone: String) async throws {
        try await remote.updatePhone(uid: uid, phone: phone)
        try await refresh(uid: uid)
    }
}
