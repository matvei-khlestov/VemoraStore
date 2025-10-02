//
//  EditPhoneViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Combine

protocol EditPhoneViewModelProtocol: BaseEditFieldViewModelProtocol, AnyObject {
    var currentPhone: String { get }
    var phoneError: AnyPublisher<String?, Never> { get }
    var phonePublisher: AnyPublisher<String, Never> { get }
    var currentError: String? { get }
    func setPhone(_ value: String)
}
