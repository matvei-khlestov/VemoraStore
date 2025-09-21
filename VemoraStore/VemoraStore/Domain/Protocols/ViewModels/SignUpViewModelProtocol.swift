//
//  SignUpViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 19.09.2025.
//

import Foundation
import Combine

protocol SignUpViewModelProtocol: AnyObject {
    // Inputs
    func setName(_ value: String)
    func setEmail(_ value: String)
    func setPassword(_ value: String)
    func setAgreement(_ value: Bool)

    // Outputs (bind)
    var nameError: AnyPublisher<String?, Never> { get }
    var emailError: AnyPublisher<String?, Never> { get }
    var passwordError: AnyPublisher<String?, Never> { get }
    var agreementError: AnyPublisher<String?, Never> { get }
    var isSubmitEnabled: AnyPublisher<Bool, Never> { get }

    // Action
    func signUp() async throws
}
