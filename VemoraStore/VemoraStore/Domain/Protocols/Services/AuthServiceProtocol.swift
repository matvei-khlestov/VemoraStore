//
//  AuthServiceProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

/// Сервис аутентификации, отвечающий за вход, регистрацию и управление сессией пользователя.
/// Используется как абстракция над конкретной реализацией (например, FirebaseAuth).
protocol AuthServiceProtocol {
    /// Паблишер, уведомляющий об изменении статуса авторизации (`true` — пользователь вошёл).
    var isAuthorizedPublisher: AnyPublisher<Bool, Never> { get }

    /// Выполняет вход пользователя по email и паролю.
    func signIn(email: String, password: String) async throws

    /// Регистрирует нового пользователя.
    func signUp(email: String, password: String) async throws

    /// Завершает текущую сессию пользователя.
    func signOut() async throws

    /// Удаляет учётную запись пользователя.
    func deleteAccount() async throws

    /// Уникальный идентификатор текущего авторизованного пользователя (если есть).
    var currentUserId: String? { get }
}
