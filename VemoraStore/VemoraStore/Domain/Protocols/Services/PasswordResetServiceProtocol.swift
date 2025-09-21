//
//  PasswordResetServiceProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 21.09.2025.
//

import Foundation

protocol PasswordResetServiceProtocol: AnyObject {
    /// Отправляет письмо для смены пароля на указанный e-mail.
    func sendPasswordReset(email: String) async throws
}
