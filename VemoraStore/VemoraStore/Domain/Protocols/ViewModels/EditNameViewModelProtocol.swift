//
//  EditNameViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Combine

/// Протокол ViewModel для экрана редактирования имени пользователя.
///
/// Отвечает за валидацию и обновление имени, обработку ошибок и
/// реактивное обновление интерфейса при вводе данных.
/// Наследуется от `BaseEditFieldViewModelProtocol` для унификации поведения
/// экранов редактирования профиля.

protocol EditNameViewModelProtocol: BaseEditFieldViewModelProtocol, AnyObject {
    
    // MARK: - Outputs
    
    /// Текущее значение имени пользователя.
    var currentName: String { get }
    
    /// Текущее сообщение об ошибке валидации.
    var currentError: String? { get }
    
    /// Паблишер ошибок валидации имени.
    var nameError: AnyPublisher<String?, Never> { get }
    
    /// Паблишер значения имени пользователя.
    var namePublisher: AnyPublisher<String, Never> { get }
    
    // MARK: - Inputs
    
    /// Устанавливает новое значение имени пользователя.
    func setName(_ value: String)
}
