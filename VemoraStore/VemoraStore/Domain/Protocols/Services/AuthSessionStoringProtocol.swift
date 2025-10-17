//
//  AuthSessionStoringProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 02.10.2025.
//

import Foundation

/// Протокол `AuthSessionStoringProtocol`
///
/// Определяет контракт для хранения и управления
/// данными пользовательской сессии (ID пользователя и тип авторизации).
///
/// Основные задачи:
/// - сохранение данных активной сессии после успешного входа;
/// - восстановление сохранённой сессии при запуске приложения;
/// - очистка данных при выходе из аккаунта.
///
/// Используется в:
/// - `AuthService` для управления состоянием авторизации;
/// - `SessionManager` для восстановления текущего пользователя.

protocol AuthSessionStoringProtocol: AnyObject {
    
    /// Идентификатор текущего пользователя, если сессия активна.
    var userId: String? { get }
    
    /// Провайдер авторизации (например, `"email"` или `"apple"`).
    var authProvider: String? { get }

    /// Сохраняет данные активной сессии.
    /// - Parameters:
    ///   - userId: Уникальный идентификатор пользователя.
    ///   - provider: Тип авторизационного провайдера.
    func saveSession(userId: String, provider: String)
    
    /// Очищает данные сессии при выходе пользователя.
    func clearSession()
}
