//
//  BaseEditFieldViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Combine
import Foundation

/// Базовый протокол ViewModel для экранов редактирования полей профиля.
///
/// Определяет общий интерфейс для редактирования отдельных полей
/// (например, имени, e-mail, телефона) с поддержкой валидации,
/// реактивного обновления состояния и подтверждения изменений.
///
/// Используется как основа для специализированных ViewModel,
/// таких как `EditNameViewModelProtocol`, `EditEmailViewModelProtocol` и т.д.

protocol BaseEditFieldViewModelProtocol: AnyObject {
    
    // MARK: - Outputs
    
    /// Текущее значение редактируемого поля.
    var currentValue: String { get }
    
    /// Паблишер ошибок валидации поля.
    var error: AnyPublisher<String?, Never> { get }
    
    /// Паблишер, определяющий доступность кнопки подтверждения.
    var isSubmitEnabled: AnyPublisher<Bool, Never> { get }
    
    // MARK: - Inputs
    
    /// Устанавливает новое значение редактируемого поля.
    func setValue(_ value: String)
    
    // MARK: - Actions
    
    /// Отправляет изменения и выполняет сохранение данных.
    func submit() async throws
}
