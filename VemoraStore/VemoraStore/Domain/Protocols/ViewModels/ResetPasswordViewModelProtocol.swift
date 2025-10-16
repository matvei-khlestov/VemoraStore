//
//  ResetPasswordViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 21.09.2025.
//

import Foundation
import Combine

/// Протокол ViewModel для экрана восстановления пароля.
///
/// Отвечает за валидацию введённого e-mail, отображение ошибок и выполнение запроса на сброс пароля.
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
