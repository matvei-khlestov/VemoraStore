//
//  LoginViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import FactoryKit

final class LoginViewModel {
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = Container.shared.authService()) {
        self.authService = authService
    }
}
