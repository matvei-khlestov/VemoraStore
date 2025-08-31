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
    
    // MARK: - Init
    init(
        product: Product,
        favoritesService: FavoritesServiceProtocol = Container.shared.favoritesService(),
        cartService: CartServiceProtocol = Container.shared.cartService()
    ) {
        self.product = product
        self.favoritesService = favoritesService
        self.cartService = cartService
    }
    
    // MARK: - Outputs (для UI)
    var title: String { product.name }
    var description: String { product.description }
    var priceText: String { "\(product.price) ₽" }
    
    var isFavorite: Bool {
        favoritesService.isFavorite(product.id)
    }
    
    // MARK: - Actions
    func toggleFavorite() {
        favoritesService.toggle(productId: product.id)
    }
    
    func addToCart() {
        cartService.add(product: product)
    }
}
