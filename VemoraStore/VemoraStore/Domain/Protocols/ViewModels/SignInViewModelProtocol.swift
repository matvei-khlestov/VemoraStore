//
//  SignInViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 21.09.2025.
//

import Foundation
import Combine

protocol SignInViewModelProtocol: AnyObject {
    // Inputs
    func setEmail(_ value: String)
    func setPassword(_ value: String)
    
    // Outputs
    var emailError: AnyPublisher<String?, Never> { get }
    var passwordError: AnyPublisher<String?, Never> { get }
    var isSubmitEnabled: AnyPublisher<Bool, Never> { get }
    
    // Actions
    func signIn() async throws
}
