//
//  Container+ViewModels.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import FactoryKit

extension Container {
    
    // MARK: - Auth
    
    var loginViewModel: Factory<LoginViewModel> {
        self { LoginViewModel(authService: self.authService()) }
    }

    // MARK: - Catalog
    
    var catalogViewModel: Factory<CatalogViewModel> {
        self { CatalogViewModel(productService: self.productService()) }
    }
    
    var productDetailsViewModel: ParameterFactory<Product, ProductDetailsViewModel> {
        self { product in
            ProductDetailsViewModel(
                product: product,
                favoritesService: self.favoritesService(),
                cartService: self.cartService()
            )
        }
    }

    // MARK: - Favorites
    
    var favoritesViewModel: Factory<FavoritesViewModel> {
        self { FavoritesViewModel(favoritesService: self.favoritesService(),
                                  productService: self.productService()) }
    }

    // MARK: - Cart
    
    var cartViewModel: Factory<CartViewModel> {
        self { CartViewModel(cartService: self.cartService()) }
    }

    // MARK: - Profile
    
    var profileViewModel: Factory<ProfileViewModel> {
        self { ProfileViewModel(profileService: self.profileService(),
                                authService: self.authService()) }
    }

    // MARK: - Checkout
    
    var checkoutViewModel: Factory<CheckoutViewModel> {
        self { CheckoutViewModel(cart: self.cartService(),
                                 auth: self.authService()) }
    }
}
