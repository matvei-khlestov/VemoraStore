//
//  CartViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import FactoryKit

final class CartViewModel {
    
    private let cartService: CartServiceProtocol
    
    init(cartService: CartServiceProtocol = Container.shared.cartService()) {
        self.cartService = cartService
    }
}
