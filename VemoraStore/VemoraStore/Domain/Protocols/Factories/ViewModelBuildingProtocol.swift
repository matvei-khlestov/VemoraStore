//
//  ViewModelBuildingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 22.09.2025.
//

import Foundation

protocol ViewModelBuildingProtocol {
    
    // MARK: - Auth
    
    func makeSignUpViewModel() -> SignUpViewModelProtocol
    func makeSignInViewModel() -> SignInViewModelProtocol
    func makeResetPasswordViewModel() -> ResetPasswordViewModelProtocol
    
    // MARK: - Catalog
    
    func makeCatalogViewModel() -> CatalogViewModelProtocol
    func makeProductDetailsViewModel(product: Product) -> ProductDetailsViewModelProtocol
    
    // MARK: - Favorites
    
    func makeFavoritesViewModel() -> FavoritesViewModelProtocol
    
    // MARK: - Cart
    
    func makeCartViewModel() -> CartViewModelProtocol
    
    // MARK: - Profile
    
    func makeProfileUserViewModel() -> ProfileUserViewModelProtocol
    func makeEditProfileViewModel() -> EditProfileViewModelProtocol
    func makeEditNameViewModel() -> EditNameViewModelProtocol
    
    // MARK: - Checkout
    
    func makeCheckoutViewModel() -> CheckoutViewModelProtocol
    
    // MARK: - Orders
    
    func makeOrdersViewModel() -> OrdersViewModelProtocol
    
    // MARK: - Delivery
    
    func makeDeliveryDetailsViewModel(baseAddress: String) -> DeliveryDetailsViewModelProtocol
    func makeAddressConfirmSheetViewModel() -> AddressConfirmSheetViewModelProtocol
    
    // MARK: - Sheets
    
    func makePhoneInputSheetViewModel(
        kind: PhoneOrCommentInputSheetViewModel.Kind,
        initialPhone: String?,
        initialComment: String?
    ) -> PhoneOrCommentInputSheetViewModelProtocol
    
    // MARK: - Map Picker
    
    func makeMapPickerViewModel() -> MapPickerViewModelProtocol
}
