//
//  EditPhoneViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Combine

/// Протокол ViewModel для экрана редактирования номера телефона пользователя.
///
/// Отвечает за валидацию, форматирование и обновление телефонного номера,
/// а также за реактивное обновление интерфейса при изменении данных.
/// Наследуется от `BaseEditFieldViewModelProtocol` для унификации логики
/// экранов редактирования профиля.

protocol EditPhoneViewModelProtocol: BaseEditFieldViewModelProtocol, AnyObject {
    
    // MARK: - Outputs
    
    /// Текущее значение номера телефона пользователя.
    var currentPhone: String { get }
    
    /// Паблишер ошибок валидации телефона.
    var phoneError: AnyPublisher<String?, Never> { get }
    
    /// Паблишер текущего значения телефона.
    var phonePublisher: AnyPublisher<String, Never> { get }
    
    /// Текущее сообщение об ошибке валидации.
    var currentError: String? { get }
    
    // MARK: - Inputs
    
    /// Устанавливает новое значение номера телефона.
    func setPhone(_ value: String)
}
