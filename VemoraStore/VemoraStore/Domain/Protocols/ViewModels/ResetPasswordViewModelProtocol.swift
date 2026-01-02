//
//  ResetPasswordViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 21.09.2025.
//

import Foundation
import Combine

/// Протокол `ResetPasswordViewModelProtocol` описывает интерфейс ViewModel
/// для экрана восстановления пароля.
///
/// Отвечает за:
/// - приём и валидацию e-mail пользователя;
/// - управление состоянием доступности кнопки восстановления;
/// - выполнение асинхронного запроса на сброс пароля.
///
/// Основные задачи:
/// - обеспечивает реактивную проверку корректности e-mail;
/// - публикует ошибки и флаг активности кнопки через Combine;
/// - инкапсулирует вызов сервиса `PasswordResetServiceProtocol`.

protocol ResetPasswordViewModelProtocol: AnyObject {
    
    // MARK: - Inputs
    
    /// Устанавливает e-mail пользователя для восстановления пароля.
    func setEmail(_ value: String)
    
    // MARK: - Outputs
    
    /// Ошибка валидации e-mail.
    var emailError: AnyPublisher<String?, Never> { get }
    
    /// Флаг, разрешающий активацию кнопки восстановления пароля.
    var isSubmitEnabled: AnyPublisher<Bool, Never> { get }
    
    // MARK: - Actions
    
    /// Отправляет запрос на восстановление пароля по введённому e-mail.
    func resetPassword() async throws
}
