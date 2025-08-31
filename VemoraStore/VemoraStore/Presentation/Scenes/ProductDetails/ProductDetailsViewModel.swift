//
//  ProductDetailsViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import FactoryKit

final class ProductDetailsViewModel {
    
    private let product: Product
    private let favoritesService: FavoritesServiceProtocol
    private let cartService: CartServiceProtocol
    
    init(
        product: Product,
        favoritesService: FavoritesServiceProtocol = Container.shared.favoritesService(),
        cartService: CartServiceProtocol = Container.shared.cartService()
    ) {
        self.product = product
        self.favoritesService = favoritesService
        self.cartService = cartService
    }
}
