//
//  EditEmailViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Foundation
import Combine

protocol EditEmailViewModelProtocol: BaseEditFieldViewModelProtocol, AnyObject {
    var currentEmail: String { get }
    var emailError: AnyPublisher<String?, Never> { get }
    func setEmail(_ value: String)
}
