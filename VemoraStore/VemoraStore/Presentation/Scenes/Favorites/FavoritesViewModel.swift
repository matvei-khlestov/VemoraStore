//
//  FavoritesViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import FactoryKit

final class FavoritesViewModel {
    
    private let favoritesService: FavoritesServiceProtocol
    private let productService: ProductServiceProtocol
    
    init(
        favoritesService: FavoritesServiceProtocol = Container.shared.favoritesService(),
        productService: ProductServiceProtocol = Container.shared.productService()
    ) {
        self.favoritesService = favoritesService
        self.productService = productService
    }
}
