//
//  EditEmailViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Combine

/// Протокол ViewModel для экрана редактирования e-mail пользователя.
///
/// Отвечает за валидацию и обновление адреса электронной почты,
/// обработку ошибок и реактивное обновление интерфейса при изменении данных.
/// Наследуется от `BaseEditFieldViewModelProtocol` для унификации логики
/// экранов редактирования профиля.

protocol EditEmailViewModelProtocol: BaseEditFieldViewModelProtocol, AnyObject {
    
    // MARK: - Outputs
    
    /// Текущее значение e-mail пользователя.
    var currentEmail: String { get }
    
    /// Паблишер ошибок валидации e-mail.
    var emailError: AnyPublisher<String?, Never> { get }
    
    /// Паблишер текущего значения e-mail.
    var emailPublisher: AnyPublisher<String, Never> { get }
    
    /// Текущее сообщение об ошибке.
    var currentError: String? { get }
    
    /// Вызывается, когда для обновления e-mail требуется подтверждение текущим паролем.
    var onPasswordRequired: (() -> Void)? { get set }
    
    // MARK: - Inputs
    
    /// Устанавливает новое значение e-mail пользователя.
    func setEmail(_ value: String)
    
    /// Инициирует сохранение и, при необходимости, запрашивает подтверждение паролем.
    func submit() async throws
    
    /// Завершает сохранение с подтверждением текущим паролем пользователя.
    func submit(withPassword password: String) async throws
}
