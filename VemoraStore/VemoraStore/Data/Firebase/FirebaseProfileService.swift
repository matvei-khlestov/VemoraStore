//
//  FirebaseProfileService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation

final class FirebaseProfileService: ProfileServiceProtocol {

    // моковое хранилище; позже заменишь на реальный стор (Keychain/Firestore/…)
    private var storedName: String = "Матвей"

    var currentName: String { storedName }

    func updateName(_ value: String) async throws {
        // имитация сети/бэкэнда
        try await Task.sleep(nanoseconds: 300_000_000)
        storedName = value
    }
}
