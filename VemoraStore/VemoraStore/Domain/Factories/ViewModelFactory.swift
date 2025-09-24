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

    func makeProductDetailsViewModel(product: Product) -> ProductDetailsViewModelProtocol {
        container.productDetailsViewModel(product)
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

    func makeProfileUserViewModel() -> ProfileUserViewModelProtocol {
        container.profileUserViewModel()
    }

    func makeEditProfileViewModel() -> EditProfileViewModelProtocol {
        container.editProfileViewModel()
    }

    func makeEditNameViewModel() -> EditNameViewModelProtocol {
        container.editNameViewModel()
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

    func makePhoneInputSheetViewModel(
        kind: PhoneOrCommentInputSheetViewModel.Kind,
        initialPhone: String?,
        initialComment: String?
    ) -> PhoneOrCommentInputSheetViewModelProtocol {
        container.phoneInputSheetViewModel((kind, initialPhone, initialComment))
    }

    // MARK: - Map Picker

    func makeMapPickerViewModel() -> MapPickerViewModelProtocol {
        container.mapPickerViewModel()
    }
}
