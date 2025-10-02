//
//  PhoneInputSheetViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 01.10.2025.
//

import Combine

protocol PhoneInputSheetViewModelProtocol: AnyObject {
    var phone: String { get }
    var currentError: String? { get }
    var phonePublisher: AnyPublisher<String, Never> { get }
    var errorPublisher: AnyPublisher<String?, Never> { get }

    func setPhone(_ value: String)
    /// Возвращает true, если номер валиден. Внутри обновляет currentError.
    @discardableResult
    func validate() -> Bool
}
