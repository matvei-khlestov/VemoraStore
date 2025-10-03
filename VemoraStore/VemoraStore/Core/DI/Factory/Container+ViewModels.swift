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
                let auth = self.authService()
                let repo = self.profileRepository(auth.currentUserId ?? "")
                return SignUpViewModel(
                    auth: auth,
                    profileRepo: repo,
                    validator: self.formValidator()
                )
            }
        }
    
    var signInViewModel: Factory<SignInViewModelProtocol> {
        self {
            SignInViewModel(
                auth: self.authService(),
                validator: self.formValidator()
            )
        }
    }
    
    var passwordResetViewModel: Factory<ResetPasswordViewModelProtocol> {
        self {
            ResetPasswordViewModel(
                service: self.passwordResetService(),
                validator: self.formValidator()
            )
        }
    }
    
    // MARK: - Catalog
    
    var catalogViewModel: Factory<CatalogViewModelProtocol> {
        self { CatalogViewModel(productService: self.productService()) }.singleton
    }
    
    var productDetailsViewModel: ParameterFactory<ProductTest, ProductDetailsViewModelProtocol> {
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
        self {
            FavoritesViewModel(
                favoritesService: self.favoritesService(),
                productService: self.productService()
            )
        }.singleton
    }
    
    // MARK: - Cart
    
    var cartViewModel: Factory<CartViewModelProtocol> {
        self {
            CartViewModel(cartService: self.cartService())
        }.singleton
    }
    
    // MARK: - Profile
    
    var profileUserViewModel: Factory<ProfileUserViewModelProtocol> {
        self {
            ProfileUserViewModel(
                auth: self.authService(),
                avatarStorage: self.avatarStorageService()
            )
        }.singleton
    }
    
    var editProfileViewModel: Factory<EditProfileViewModelProtocol> {
        self { EditProfileViewModel(avatarStorage: self.avatarStorageService()) }
    }
    
    var editNameViewModel: Factory<EditNameViewModelProtocol> {
        self {
            EditNameViewModel(
                profile: self.profileService(),
                validator: self.formValidator()
            )
        }
    }
    
    var editEmailViewModel: Factory<EditEmailViewModelProtocol> {
        self {
            EditEmailViewModel(
                profile: self.profileService(),
                validator: self.formValidator()
            )
        }
    }
    
    var editPhoneViewModel: Factory<EditPhoneViewModelProtocol> {
        self {
            EditPhoneViewModel(
                profile: self.profileService(),
                validator: self.formValidator()
            )
        }
    }
    
    // MARK: - Checkout
    
    var checkoutViewModel: Factory<CheckoutViewModelProtocol> {
        self {
            CheckoutViewModel(
                cart: self.cartService(),
                auth: self.authService(),
                phoneFormatter: self.phoneFormatter()
            )
        }
    }
    
    // MARK: - Orders
    
    var ordersViewModel: Factory<OrdersViewModelProtocol> {
        self {
            OrdersViewModel(service: self.ordersService())
        }
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
    
    var phoneInputSheetViewModel: ParameterFactory<String?, PhoneInputSheetViewModelProtocol> {
        self { initialPhone in
            PhoneInputSheetViewModel(
                initialPhone: initialPhone,
                validator: self.formValidator()
            )
        }
    }
    
    // MARK: - Comment Input
    
    var commentInputSheetViewModel: ParameterFactory<String?, CommentInputSheetViewModelProtocol> {
        self { initialComment in
            CommentInputSheetViewModel(
                initialComment: initialComment,
                validator: self.formValidator()
            )
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
    
    // MARK: - Debug
    
#if DEBUG
    var debugImportViewModel: Factory<DebugImportViewModelProtocol> {
        self {
            DebugImportViewModel(
                debugImportStorage: self.debugImportStorage(),
                debugImporter: self.debugImporter()
            )
        }
    }
#endif
}
