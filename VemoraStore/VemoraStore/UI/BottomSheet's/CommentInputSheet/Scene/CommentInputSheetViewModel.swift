//
//  CommentInputSheetViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 01.10.2025.
//

import Foundation
import Combine

/// ViewModel `CommentInputSheetViewModel` для экрана добавления комментария.
///
/// Основные задачи:
/// - Хранение и обновление текста комментария;
/// - Валидация введённого текста через `FormValidatingProtocol`;
/// - Управление ошибками валидации;
/// - Реактивное оповещение View об изменениях состояния.
///
/// Обеспечивает реактивные обновления через Combine:
/// - `commentPublisher` — поток текста комментария;
/// - `errorPublisher` — поток ошибок валидации.
///
/// После исправления текста автоматически очищает ошибку,
/// если введённое значение прошло успешную проверку.
///
/// Используется для форм с пользовательскими комментариями
/// или текстовыми отзывами перед отправкой на сервер.

final class CommentInputSheetViewModel: CommentInputSheetViewModelProtocol {

    // MARK: - Deps
    
    private let validator: FormValidatingProtocol

    // MARK: - State
    
    @Published private var _comment: String
    @Published private var _error: String? = nil

    var currentError: String? { _error }

    private var bag = Set<AnyCancellable>()

    // MARK: - Init
    
    init(
        initialComment: String? = nil,
        validator: FormValidatingProtocol
    ) {
        self.validator = validator
        self._comment = initialComment ?? ""

        $_comment
            .dropFirst()
            .sink { [weak self] value in
                guard let self else { return }
                if self._error != nil, self.validator.validate(value, for: .comment).isValid {
                    self._error = nil
                }
            }
            .store(in: &bag)
    }

    // MARK: - Outputs
    
    var comment: String { _comment }

    var commentPublisher: AnyPublisher<String, Never> {
        $_comment.eraseToAnyPublisher()
    }

    var errorPublisher: AnyPublisher<String?, Never> {
        $_error.eraseToAnyPublisher()
    }

    // MARK: - Inputs
    
    func setComment(_ value: String) {
        _comment = value
    }

    // MARK: - Validation
    
    @discardableResult
    func validate() -> Bool {
        let result = validator.validate(_comment, for: .comment)
        _error = result.message
        return result.isValid
    }
}
