//
//  ResetPasswordViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 21.09.2025.
//

import Foundation
import Combine

protocol ResetPasswordViewModelProtocol: AnyObject {
    // Inputs
    func setEmail(_ value: String)
    
    // Outputs
    var emailError: AnyPublisher<String?, Never> { get }
    var isSubmitEnabled: AnyPublisher<Bool, Never> { get }
    
    // Action
    func resetPassword() async throws
}
