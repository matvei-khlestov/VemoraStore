//
//  FirebaseProfileService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

final class FirebaseProfileService: ProfileServiceProtocol {
    // Простейшее in-memory хранилище профилей для заглушки
    private var storage: [String: Profile] = [:]
    private let lock = NSLock()

    func loadProfile(uid: String) -> AnyPublisher<Profile, any Error> {
        // Возвращаем сохранённый профиль или дефолтный
        let profile: Profile = {
            lock.lock(); defer { lock.unlock() }
            if let p = storage[uid] { return p }
            return Profile(uid: uid,
                           displayName: "Vemora User",
                           email: "user@example.com",
                           photoURL: nil)
        }()

        return Just(profile)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func updateProfile(_ profile: Profile, avatar: Data?) async throws {
        // Эмулируем задержку сети и «сохраняем» профиль в память
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3s
        lock.lock()
        storage[profile.uid] = profile
        lock.unlock()
        // avatar в заглушке игнорируем; в бою сюда пойдёт upload в Firebase Storage
    }
}
