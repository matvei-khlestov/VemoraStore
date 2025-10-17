//
//  PasswordResetServiceProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 21.09.2025.
//

import Foundation

/// Протокол `PasswordResetServiceProtocol`
///
/// Определяет интерфейс для сервиса восстановления пароля.
/// Отвечает за отправку письма с инструкцией для смены пароля на указанный e-mail.
///
/// Основные задачи:
/// - проверка существования пользователя с данным e-mail;
/// - инициирование сброса пароля на стороне сервера или через сторонний сервис (например, Firebase);
/// - предоставление асинхронного API для безопасной обработки ошибок.
///
/// Используется в:
/// - `ResetPasswordViewModel` и `ResetPasswordViewController`
///   для выполнения запроса восстановления пароля и уведомления пользователя о результате.

protocol PasswordResetServiceProtocol: AnyObject {
    
    /// Отправляет письмо для восстановления пароля на указанный e-mail.
    /// - Parameter email: Электронная почта пользователя, на которую будет отправлено письмо.
    /// - Throws: Ошибку, если адрес не найден или произошёл сбой при отправке.
    func sendPasswordReset(email: String) async throws
}
