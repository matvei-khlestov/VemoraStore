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
    
    
    
    // MARK: - Checkout
    
    var checkoutViewModel: Factory<CheckoutViewModel> {
        self { CheckoutViewModel(cart: self.cartService(),
                                 auth: self.authService()) }
    }
    
    
    // MARK: - Address / Delivery
    
    var deliveryDetailsViewModel: ParameterFactory<String, DeliveryDetailsViewModelProtocol> {
        self { baseAddress in
            DeliveryDetailsViewModel(baseAddress: baseAddress)
        }
    }
    
    // MARK: - Address Confirm
    
    var addressConfirmSheetViewModel: Factory<AddressConfirmSheetViewModelProtocol> {
        self {
            AddressConfirmSheetViewModel(
                search: self.addressSearchService(),
                formatter: self.addressFormatter()
            )
        }
    }
    
    // MARK: - Phone Input
    
    var phoneInputSheetViewModel: ParameterFactory<(PhoneOrCommentInputSheetViewModel.Kind, String?, String?), PhoneOrCommentInputSheetViewModelProtocol> {
        self { (kind, initialPhone, initialComment) in
            PhoneOrCommentInputSheetViewModel(kind: kind, initialPhone: initialPhone, initialComment: initialComment)
        }
    }
    
    // MARK: - Map Picker
    
    var mapPickerViewModel: Factory<MapPickerViewModelProtocol> {
        self { MapPickerViewModel(container: self) }
    }
}
