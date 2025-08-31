//
//  CheckoutViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import FactoryKit

final class CheckoutViewModel {
    
    private let cartService: CartServiceProtocol
    private let authService: AuthServiceProtocol
    
    init(
        cart: CartServiceProtocol = Container.shared.cartService(),
        auth: AuthServiceProtocol = Container.shared.authService()
    ) {
        self.cartService = cart
        self.authService = auth
    }
}
