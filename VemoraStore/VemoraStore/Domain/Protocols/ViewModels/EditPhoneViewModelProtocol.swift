//
//  EditPhoneViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Foundation
import Combine

protocol EditPhoneViewModelProtocol: BaseEditFieldViewModelProtocol, AnyObject {
    var currentPhone: String { get }
    var phoneError: AnyPublisher<String?, Never> { get }
    func setPhone(_ value: String)
}
