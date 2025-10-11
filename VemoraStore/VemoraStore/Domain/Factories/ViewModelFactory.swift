//
//  ViewModelFactory.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import Foundation
import FactoryKit

final class ViewModelFactory: ViewModelBuildingProtocol {
    
    private let container: Container
    
    init(container: Container) {
        self.container = container
    }
    
    // MARK: - Auth
    
    func makeSignUpViewModel() -> SignUpViewModelProtocol {
        container.signUpViewModel()
    }
    
    func makeSignInViewModel() -> SignInViewModelProtocol {
        container.signInViewModel()
    }
    
    func makeResetPasswordViewModel() -> ResetPasswordViewModelProtocol {
        container.passwordResetViewModel()
    }
    
    // MARK: - Catalog
    
    func makeCatalogViewModel() -> CatalogViewModelProtocol {
        container.catalogViewModel()
    }
    
    func makeCatalogFilterViewModel() -> CatalogFilterViewModelProtocol {
        container.catalogFilterViewModel()
    }
    
    func makeProductDetailsViewModel(product: Product) -> ProductDetailsViewModelProtocol {
        container.productDetailsViewModel(product)
    }

    func makeCategoryProductsViewModel(categoryId: String) -> CategoryProductsViewModelProtocol {
        container.categoryProductsViewModel(categoryId)
    }
    
    // MARK: - Favorites
    
    func makeFavoritesViewModel() -> FavoritesViewModelProtocol {
        container.favoritesViewModel()
    }
    
    // MARK: - Cart
    
    func makeCartViewModel() -> CartViewModelProtocol {
        container.cartViewModel()
    }
    
    // MARK: - Profile
    
    func makeProfileUserViewModel(uid: String) -> ProfileUserViewModelProtocol {
        container.profileUserViewModel(uid)
    }
    
    func makeEditProfileViewModel(userId: String) -> EditProfileViewModelProtocol {
        container.editProfileViewModel(userId)
    }
    
    func makeEditNameViewModel(uid: String) -> EditNameViewModelProtocol {
        container.editNameViewModel(uid)
    }
    
    func makeEditEmailViewModel(userId: String) -> EditEmailViewModelProtocol {
        container.editEmailViewModel(userId)
    }
    
    func makeEditPhoneViewModel(userId: String) -> EditPhoneViewModelProtocol {
        container.editPhoneViewModel(userId)
    }
    
    // MARK: - Checkout
    
    func makeCheckoutViewModel() -> CheckoutViewModelProtocol {
        container.checkoutViewModel()
    }
    
    // MARK: - Orders
    
    func makeOrdersViewModel() -> OrdersViewModelProtocol {
        container.ordersViewModel()
    }
    
    // MARK: - Address / Delivery
    
    func makeDeliveryDetailsViewModel(baseAddress: String) -> DeliveryDetailsViewModelProtocol {
        container.deliveryDetailsViewModel(baseAddress)
    }
    
    func makeAddressConfirmSheetViewModel() -> AddressConfirmSheetViewModelProtocol {
        container.addressConfirmSheetViewModel()
    }
    
    // MARK: - Phone Input
    
    func makePhoneInputSheetViewModel(initialPhone: String? = nil) -> PhoneInputSheetViewModelProtocol {
        container.phoneInputSheetViewModel(initialPhone)
    }
    
    // MARK: - Comment Input
    
    func makeCommentInputSheetViewModel(initialComment: String? = nil) -> CommentInputSheetViewModelProtocol {
        container.commentInputSheetViewModel(initialComment)
    }
    
    // MARK: - Map Picker
    
    func makeMapPickerViewModel() -> MapPickerViewModelProtocol {
        container.mapPickerViewModel()
    }
    
    // MARK: - Debug
    
#if DEBUG
    func makeDebugImortViewModel() -> DebugImportViewModelProtocol {
        container.debugImportViewModel()
    }
#endif
}
