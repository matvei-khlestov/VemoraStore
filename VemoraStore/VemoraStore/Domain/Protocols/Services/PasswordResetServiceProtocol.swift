//
//  PasswordResetServiceProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 21.09.2025.
//

import Foundation

/// Протокол для сервиса восстановления пароля.
///
/// Отвечает за отправку писем с инструкцией для смены пароля.
protocol PasswordResetServiceProtocol: AnyObject {
    /// Отправляет письмо для восстановления пароля на указанный e-mail.
    func sendPasswordReset(email: String) async throws
}
