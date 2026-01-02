//
//  CommentInputSheetViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 01.10.2025.
//

import Combine

/// Контракт `CommentInputSheetViewModelProtocol`
/// для ViewModel экрана ввода комментария.
///
/// Определяет минимальный набор свойств и методов
/// для хранения, валидации и реактивного обновления
/// состояния текстового комментария.
///
/// Используется во `CommentInputSheetViewController`
/// для биндинга UI и проверки введённого текста.
///
/// Основные обязанности:
/// - Хранить текущее значение комментария (`comment`);
/// - Публиковать изменения текста и ошибок (`commentPublisher`, `errorPublisher`);
/// - Выполнять валидацию значения через `FormValidatingProtocol`;
/// - Обновлять `currentError` в случае невалидного ввода.
///
/// Возвращает `true` при успешной валидации комментария
/// и `false`, если введённый текст не соответствует требованиям.

protocol CommentInputSheetViewModelProtocol: AnyObject {

    // MARK: - Outputs
    
    /// Текущий комментарий.
    var comment: String { get }
    
    /// Текущая ошибка валидации.
    var currentError: String? { get }

    // MARK: - Publishers
    
    /// Паблишер изменений комментария.
    var commentPublisher: AnyPublisher<String, Never> { get }
    
    /// Паблишер ошибок валидации.
    var errorPublisher: AnyPublisher<String?, Never> { get }

    // MARK: - Inputs
    
    /// Устанавливает новое значение комментария.
    func setComment(_ value: String)
    
    /// Проверяет валидность комментария.
    @discardableResult
    func validate() -> Bool
}
