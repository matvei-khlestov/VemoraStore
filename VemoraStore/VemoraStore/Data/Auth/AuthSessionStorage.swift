//
//  AuthSessionStorage.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 02.10.2025.
//

final class AuthSessionStorage: AuthSessionStoringProtocol {

    private let keychain: KeychainServiceProtocol

    init(keychain: KeychainServiceProtocol) {
        self.keychain = keychain
    }

    // MARK: - Read

    var userId: String? {
        keychain.get(.userId)
    }

    var authProvider: String? {
        keychain.get(.authProvider)
    }

    // MARK: - Write

    func saveSession(userId: String, provider: String) {
        keychain.set(userId, for: .userId)
        keychain.set(provider, for: .authProvider)
    }

    func clearSession() {
        _ = keychain.remove(.userId)
        _ = keychain.remove(.authProvider)
    }
}
