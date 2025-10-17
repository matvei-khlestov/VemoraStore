//
//  AuthSessionStorage.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 02.10.2025.
//

import Foundation

/// Класс `AuthSessionStorage`
///
/// Реализует протокол `AuthSessionStoringProtocol` и отвечает
/// за безопасное хранение данных сессии пользователя с помощью `KeychainServiceProtocol`.
///
/// Основные задачи:
/// - сохранение идентификатора пользователя (`userId`) и провайдера авторизации (`authProvider`);
/// - предоставление доступа к текущим данным сессии;
/// - безопасное удаление сохранённых данных при выходе пользователя.
///
/// Используется в:
/// - `AuthService` — для управления состоянием аутентификации и восстановления сессии при запуске приложения.

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
