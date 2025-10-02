//
//  EditNameViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Combine

protocol EditNameViewModelProtocol: BaseEditFieldViewModelProtocol, AnyObject {
    var currentName: String { get }
    var currentError: String? { get }
    var nameError: AnyPublisher<String?, Never> { get }
    var namePublisher: AnyPublisher<String, Never> { get }
    func setName(_ value: String)
}
