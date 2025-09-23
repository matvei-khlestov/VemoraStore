//
//  CoordinatorBuildingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import UIKit

protocol CoordinatorBuildingProtocol {
    
    // MARK: - Catalog
    
    func makeCatalogCoordinator(
        navigation: UINavigationController
    ) -> CatalogCoordinatingProtocol
    
    // MARK: - Product Details
    
    func makeProductDetailsCoordinator(
        navigation: UINavigationController,
        product: Product
    ) -> ProductDetailsCoordinatingProtocol
    
    // MARK: - Map Picker
    
    func makeMapPickerCoordinator(
        navigation: UINavigationController
    ) -> MapPickerCoordinatingProtocol
    
    // MARK: - Checkout
    
    func makeCheckoutCoordinator(
        navigation: UINavigationController
    ) -> CheckoutCoordinatingProtocol
    
    // MARK: - Order Success
    
    func makeOrderSuccessCoordinator(
        navigation: UINavigationController
    ) -> OrderSuccessCoordinatingProtocol
    
    // MARK: - Favorites
    
    func makeFavoritesCoordinator(
        navigation: UINavigationController
    ) -> FavoritesCoordinatingProtocol
    
    // MARK: - About
    
    func makeAboutCoordinator(
        navigation: UINavigationController
    ) -> AboutCoordinatingProtocol
    
    // MARK: - Privacy Policy
    
    func makePrivacyPolicyCoordinator(
        navigation: UINavigationController
    ) -> PrivacyPolicyCoordinatingProtocol
    
    // MARK: - Contact Us
    
    func makeContactUsCoordinator(
        navigation: UINavigationController
    ) -> ContactUsCoordinatingProtocol
    
    // MARK: - Reset Password
    
    func makeResetPasswordCoordinator(
        navigation: UINavigationController
    ) -> ResetPasswordCoordinatingProtocol
    
    // MARK: - Auth
    
    func makeAuthCoordinator(
        navigation: UINavigationController
    ) -> AuthCoordinatingProtocol
    
    // MARK: - Profile Guest
    
    func makeProfileGuestCoordinator(
        navigation: UINavigationController
    ) -> ProfileGuestCoordinatingProtocol
    
    // MARK: - Profile User
    
    func makeProfileUserCoordinator(
        navigation: UINavigationController
    ) -> ProfileUserCoordinatingProtocol
    
    // MARK: - Orders
    
    func makeOrdersCoordinator(
        navigation: UINavigationController
    ) -> OrdersCoordinatingProtocol
    
    // MARK: - Cart
    
    func makeCartCoordinator(
        navigation: UINavigationController
    ) -> CartCoordinatingProtocol

    // MARK: - Main

    func makeMainCoordinator(
        navigation: UINavigationController
    ) -> MainCoordinatingProtocol

    // MARK: - App

    func makeAppCoordinator(
        navigation: UINavigationController
    ) -> AppCoordinatingProtocol
}
