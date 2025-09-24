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

    var signUpViewModel: Factory<SignUpViewModelProtocol> {
        self {
            SignUpViewModel(
                auth: self.authService(),
                validator: self.authValidator()
            )
        }
    }

    var signInViewModel: Factory<SignInViewModelProtocol> {
        self {
            SignInViewModel(
                auth: self.authService(),
                validator: self.authValidator()
            )
        }
    }
    
    var passwordResetViewModel: Factory<ResetPasswordViewModelProtocol> {
        self {
            ResetPasswordViewModel(
                service: self.passwordResetService(),
                validator: self.authValidator()
            )
        }
    }
    
    // MARK: - Catalog
    
    var catalogViewModel: Factory<CatalogViewModelProtocol> {
        self { CatalogViewModel(productService: self.productService()) }.singleton
    }
    
    var productDetailsViewModel: ParameterFactory<Product, ProductDetailsViewModelProtocol> {
        self { product in
            ProductDetailsViewModel(
                product: product,
                favoritesService: self.favoritesService(),
                cartService: self.cartService()
            )
        }
    }
    
    // MARK: - Favorites
    
    var favoritesViewModel: Factory<FavoritesViewModelProtocol> {
        self { FavoritesViewModel(favoritesService: self.favoritesService(),
                                  productService: self.productService()) }.singleton
    }
    
    // MARK: - Cart
    
    var cartViewModel: Factory<CartViewModelProtocol> {
        self { CartViewModel(cartService: self.cartService()) }.singleton
    }
    
    // MARK: - Profile
    
    var profileUserViewModel: Factory<ProfileUserViewModelProtocol> {
        self { ProfileUserViewModel(auth: self.authService()) }.singleton
    }
    
    var editProfileViewModel: Factory<EditProfileViewModelProtocol> {
        self { EditProfileViewModel(avatarStorage: self.avatarStorageService()) }
    }

    var editNameViewModel: Factory<EditNameViewModelProtocol> {
        self {
            EditNameViewModel(
                profile: self.profileService(),
                validator: self.authValidator()
            )
        }
    }
    
    var editEmailViewModel: Factory<EditEmailViewModelProtocol> {
        self {
            EditEmailViewModel(
                profile: self.profileService(),
                validator: self.authValidator()
            )
        }
    }
    
    var editPhoneViewModel: Factory<EditPhoneViewModelProtocol> {
        self {
            EditPhoneViewModel(
                profile: self.profileService(),
                validator: self.authValidator()
            )
        }
    }
    
    // MARK: - Checkout
    
    var checkoutViewModel: Factory<CheckoutViewModelProtocol> {
        self { CheckoutViewModel(cart: self.cartService(),
                                 auth: self.authService()) }
    }
    
    // MARK: - Orders
    
    var ordersViewModel: Factory<OrdersViewModelProtocol> {
        self { OrdersViewModel(service: self.ordersService()) }
    }
    
    // MARK: - Address / Delivery
    
    var deliveryDetailsViewModel: ParameterFactory<String, DeliveryDetailsViewModelProtocol> {
        self { baseAddress in
            DeliveryDetailsViewModel(
                baseAddress: baseAddress,
                formatter: self.deliveryAddressFormatter()
            )
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
        self {
            MapPickerViewModel(
                geocoder: self.geocodingService(),
                formatter: self.addressFormatter()
            )
        }
    }
}
