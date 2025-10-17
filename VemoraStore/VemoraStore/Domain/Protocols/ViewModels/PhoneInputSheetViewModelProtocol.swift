//
//  PhoneInputSheetViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 01.10.2025.
//

import Combine

/// Протокол `PhoneInputSheetViewModelProtocol`
/// описывает контракт ViewModel для экрана ввода телефона.
///
/// Отвечает за:
/// - хранение и изменение введённого телефона;
/// - валидацию значения через `FormValidatingProtocol`;
/// - публикацию актуального состояния и ошибок через Combine.
///
/// Используется во `PhoneInputSheetViewController`
/// для реактивного биндинга поля ввода и отображения ошибок.

protocol PhoneInputSheetViewModelProtocol: AnyObject {
    
    // MARK: - Outputs
    
    /// Текущее значение телефона.
    var phone: String { get }
    
    /// Текущее сообщение об ошибке.
    var currentError: String? { get }
    
    // MARK: - Publishers
    
    /// Паблишер изменений телефона.
    var phonePublisher: AnyPublisher<String, Never> { get }
    
    /// Паблишер ошибок валидации.
    var errorPublisher: AnyPublisher<String?, Never> { get }
    
    // MARK: - Inputs
    
    /// Устанавливает новое значение телефона.
    /// - Parameter value: Новая строка номера.
    func setPhone(_ value: String)
    
    /// Проверяет корректность введённого телефона.
    /// - Returns: `true`, если номер валиден.
    @discardableResult
    func validate() -> Bool
}
