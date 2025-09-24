//
//  BaseEditFieldViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Combine
import Foundation

protocol BaseEditFieldViewModelProtocol: AnyObject {
    // Outputs
    var currentValue: String { get }
    var error: AnyPublisher<String?, Never> { get }
    var isSubmitEnabled: AnyPublisher<Bool, Never> { get }

    // Inputs
    func setValue(_ value: String)

    // Actions
    func submit() async throws
}
