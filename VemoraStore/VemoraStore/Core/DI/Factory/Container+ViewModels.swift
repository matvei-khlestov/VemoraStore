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
                validator: self.formValidator(),
                makeProfileRepository: { uid in
                    self.profileRepository(uid)
                }
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
        self {
            CatalogViewModel(repository: self.catalogRepository())
        }.singleton
    }

    var catalogFilterViewModel: Factory<CatalogFilterViewModelProtocol> {
        self {
            CatalogFilterViewModel(repository: self.catalogRepository())
        }
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

    var categoryProductsViewModel: ParameterFactory<String, CategoryProductsViewModelProtocol> {
        self { categoryId in
            CategoryProductsViewModel(
                repository: self.catalogRepository(),
                categoryId: categoryId
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
    
    var profileUserViewModel: ParameterFactory<String, ProfileUserViewModelProtocol> {
        self { uid in
            ProfileUserViewModel(
                auth: self.authService(),
                avatarStorage: self.avatarStorageService(),
                profileRepository: self.profileRepository(uid),
                userId: uid
            )
        }
    }
    
    var editProfileViewModel: ParameterFactory<String, EditProfileViewModelProtocol> {
        self { userId in
            EditProfileViewModel(
                avatarStorage: self.avatarStorageService(),
                profileRepository: self.profileRepository(userId),
                userId: userId
            )
        }
    }
    
    var editNameViewModel: ParameterFactory<String, EditNameViewModelProtocol> {
        self { uid in
            EditNameViewModel(
                profileRepository: self.profileRepository(uid),
                userId: uid,
                validator: self.formValidator()
            )
        }
    }
    
    var editEmailViewModel: ParameterFactory<String, EditEmailViewModelProtocol> {
        self { userId in
            EditEmailViewModel(
                profileRepository: self.profileRepository(userId),
                validator: self.formValidator(),
                userId: userId,
            )
        }
    }
    
    var editPhoneViewModel: ParameterFactory<String, EditPhoneViewModelProtocol> {
        self { userId in
            EditPhoneViewModel(
                profileRepository: self.profileRepository(userId),
                validator: self.formValidator(),
                userId: userId
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
