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
    
    // MARK: - Inputs
    
    /// Устанавливает новое значение e-mail пользователя.
    func setEmail(_ value: String)
}
