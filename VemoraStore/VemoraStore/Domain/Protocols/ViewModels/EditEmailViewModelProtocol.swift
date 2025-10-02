//
//  EditEmailViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Combine

protocol EditEmailViewModelProtocol: BaseEditFieldViewModelProtocol, AnyObject {
    var currentEmail: String { get }
    var emailError: AnyPublisher<String?, Never> { get }
    var emailPublisher: AnyPublisher<String, Never> { get }
    var currentError: String? { get }
    func setEmail(_ value: String)
}
