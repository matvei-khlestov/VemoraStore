//
//  ViewModelBuildingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 22.09.2025.
//

import Foundation

protocol ViewModelBuildingProtocol {
    
    // Auth
    func makeSignUpViewModel() -> SignUpViewModelProtocol
    func makeSignInViewModel() -> SignInViewModelProtocol
    func makeResetPasswordViewModel() -> ResetPasswordViewModelProtocol
    
    // Catalog
    func makeCatalogViewModel() -> CatalogViewModelProtocol
    func makeProductDetailsViewModel(product: Product) -> ProductDetailsViewModelProtocol
    
    // Favorites
    func makeFavoritesViewModel() -> FavoritesViewModelProtocol
    
    // Cart
    func makeCartViewModel() -> CartViewModelProtocol
    
    // Profile
    func makeProfileUserViewModel() -> ProfileUserViewModelProtocol
    
    // Checkout
    func makeCheckoutViewModel() -> CheckoutViewModelProtocol
    
    // Orders
    func makeOrdersViewModel() -> OrdersViewModelProtocol
    
    // Address / Delivery
    func makeDeliveryDetailsViewModel(baseAddress: String) -> DeliveryDetailsViewModelProtocol
    func makeAddressConfirmSheetViewModel() -> AddressConfirmSheetViewModelProtocol
    
    // Phone Input
    func makePhoneInputSheetViewModel(
        kind: PhoneOrCommentInputSheetViewModel.Kind,
        initialPhone: String?,
        initialComment: String?
    ) -> PhoneOrCommentInputSheetViewModelProtocol
    
    // Map Picker
    func makeMapPickerViewModel() -> MapPickerViewModelProtocol
}
