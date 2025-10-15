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
    
    func makeCatalogViewModel(userId: String) -> CatalogViewModelProtocol
    func makeCatalogFilterViewModel() -> CatalogFilterViewModelProtocol
    func makeProductDetailsViewModel(productId: String, userId: String) -> ProductDetailsViewModelProtocol
    func makeCategoryProductsViewModel(categoryId: String, userId: String) -> CategoryProductsViewModelProtocol
    
    // MARK: - Favorites
    
    func makeFavoritesViewModel(userId: String) -> FavoritesViewModelProtocol
    
    // MARK: - Cart
    
    func makeCartViewModel(userId: String) -> CartViewModelProtocol
    
    // MARK: - Profile
    
    func makeProfileUserViewModel(uid: String) -> ProfileUserViewModelProtocol
    func makeEditProfileViewModel(userId: String) -> EditProfileViewModelProtocol
    func makeEditNameViewModel(uid: String) -> EditNameViewModelProtocol
    func makeEditEmailViewModel(userId: String) -> EditEmailViewModelProtocol
    func makeEditPhoneViewModel(userId: String) -> EditPhoneViewModelProtocol
    
    // MARK: - Checkout
    
    func makeCheckoutViewModel(
        userId: String,
        snapshotItems: [CartItem]
    ) -> CheckoutViewModelProtocol
    
    // MARK: - Orders
    
    func makeOrdersViewModel(userId: String) -> OrdersViewModelProtocol
    
    // MARK: - Delivery
    
    func makeDeliveryDetailsViewModel(baseAddress: String) -> DeliveryDetailsViewModelProtocol
    func makeAddressConfirmSheetViewModel() -> AddressConfirmSheetViewModelProtocol
    
    // MARK: - Sheets
    
    func makePhoneInputSheetViewModel(initialPhone: String?) -> PhoneInputSheetViewModelProtocol
    func makeCommentInputSheetViewModel(initialComment: String?) -> CommentInputSheetViewModelProtocol
    
    // MARK: - Map Picker
    
    func makeMapPickerViewModel() -> MapPickerViewModelProtocol
    
    // MARK: - Debug
    
#if DEBUG
    func makeDebugImortViewModel() -> DebugImportViewModelProtocol
#endif
}
