//
//  CommentInputSheetViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 01.10.2025.
//

import Combine

protocol CommentInputSheetViewModelProtocol: AnyObject {
    var comment: String { get }
    var currentError: String? { get }
    var commentPublisher: AnyPublisher<String, Never> { get }
    var errorPublisher: AnyPublisher<String?, Never> { get }

    func setComment(_ value: String)
    /// Возвращает true, если комментарий валиден. Внутри обновляет currentError.
    @discardableResult
    func validate() -> Bool
}
