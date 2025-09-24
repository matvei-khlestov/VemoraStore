//
//  EditPhoneViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Foundation
import Combine

protocol EditPhoneViewModelProtocol: AnyObject {
    // Outputs
    var currentPhone: String { get }
    var phoneError: AnyPublisher<String?, Never> { get }
    var isSubmitEnabled: AnyPublisher<Bool, Never> { get }
    
    // Inputs
    func setPhone(_ value: String)
    
    // Actions
    func submit() async throws
}
