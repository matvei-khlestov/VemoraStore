//
//  EditEmailViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Foundation
import Combine

protocol EditEmailViewModelProtocol: AnyObject {
    
    // MARK: - Outputs
    
    var currentEmail: String { get }
    var emailError: AnyPublisher<String?, Never> { get }
    var isSubmitEnabled: AnyPublisher<Bool, Never> { get }
    
    // MARK: - Inputs
    
    func setEmail(_ value: String)
    
    // MARK: - Actions
    
    func submit() async throws
}
