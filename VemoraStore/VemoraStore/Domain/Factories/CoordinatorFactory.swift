//
//  CoordinatorFactory.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import UIKit
import FactoryKit

final class CoordinatorFactory: CoordinatorBuildingProtocol {
    
    private let container: Container
    
    init(container: Container) {
        self.container = container
    }
    
    // MARK: - Catalog
    
    func makeCatalogCoordinator(navigation: UINavigationController) -> CatalogCoordinatingProtocol {
        container.catalogCoordinator(navigation)
    }
    
    // MARK: - Product Details
    
    func makeProductDetailsCoordinator(navigation: UINavigationController, product: ProductTest) -> ProductDetailsCoordinatingProtocol {
        container.productDetailsCoordinator((navigation, product))
    }
    
    // MARK: - Checkout
    
    func makeCheckoutCoordinator(navigation: UINavigationController) -> CheckoutCoordinatingProtocol {
        container.checkoutCoordinator(navigation)
    }
    
    // MARK: - Map Picker
    
    func makeMapPickerCoordinator(navigation: UINavigationController) -> MapPickerCoordinatingProtocol {
        container.mapPickerCoordinator(navigation)
    }
    
    // MARK: - Order Success
    
    func makeOrderSuccessCoordinator(navigation: UINavigationController) -> OrderSuccessCoordinatingProtocol {
        container.orderSuccessCoordinator(navigation)
    }
    
    // MARK: - Favorites
    
    func makeFavoritesCoordinator(navigation: UINavigationController) -> FavoritesCoordinatingProtocol {
        container.favoritesCoordinator(navigation)
    }
    
    // MARK: - About
    
    func makeAboutCoordinator(navigation: UINavigationController) -> AboutCoordinatingProtocol {
        container.aboutCoordinator(navigation)
    }
    
    // MARK: - Privacy Policy
    
    func makePrivacyPolicyCoordinator(navigation: UINavigationController) -> PrivacyPolicyCoordinatingProtocol {
        container.privacyPolicyCoordinator(navigation)
    }
    
    // MARK: - Contact Us
    
    func makeContactUsCoordinator(navigation: UINavigationController) -> ContactUsCoordinatingProtocol {
        container.contactUsCoordinator(navigation)
    }
    
    // MARK: - Reset Password
    
    func makeResetPasswordCoordinator(navigation: UINavigationController) -> ResetPasswordCoordinatingProtocol {
        container.resetPasswordCoordinator(navigation)
    }
    
    // MARK: - Auth
    
    func makeAuthCoordinator(navigation: UINavigationController) -> AuthCoordinatingProtocol {
        container.authCoordinator(navigation)
    }
    
    // MARK: - Profile Guest
    
    func makeProfileGuestCoordinator(navigation: UINavigationController) -> ProfileGuestCoordinatingProtocol {
        container.profileGuestCoordinator(navigation)
    }
    
    // MARK: - Profile User
    
    func makeProfileUserCoordinator(navigation: UINavigationController) -> ProfileUserCoordinatingProtocol {
        container.profileUserCoordinator(navigation)
    }
    
    // MARK: - Orders
    
    func makeOrdersCoordinator(navigation: UINavigationController) -> OrdersCoordinatingProtocol {
        container.ordersCoordinator(navigation)
    }
    
    // MARK: - Cart
    
    func makeCartCoordinator(navigation: UINavigationController) -> CartCoordinatingProtocol {
        container.cartCoordinator(navigation)
    }
    
    // MARK: - Edit Name
    
    func makeEditNameCoordinator(navigation: UINavigationController) -> EditNameCoordinatingProtocol {
        container.editNameCoordinator(navigation)
    }
    
    // MARK: - Edit Email
    
    func makeEditEmailCoordinator(navigation: UINavigationController) -> EditEmailCoordinatingProtocol {
        container.editEmailCoordinator(navigation)
    }
    
    // MARK: - Edit Phone
    
    func makeEditPhoneCoordinator(navigation: UINavigationController) -> EditPhoneCoordinatingProtocol {
        container.editPhoneCoordinator(navigation)
    }
    
    // MARK: - Edit Profile
    
    func makeEditProfileCoordinator(navigation: UINavigationController) -> EditProfileCoordinatingProtocol {
        container.editProfileCoordinator(navigation)
    }
    
    // MARK: - Main
    
    func makeMainCoordinator(navigation: UINavigationController) -> MainCoordinatingProtocol {
        container.mainCoordinator(navigation)
    }
    
    // MARK: - App
    
    func makeAppCoordinator(navigation: UINavigationController) -> AppCoordinatingProtocol {
        container.appCoordinator(navigation)
    }
    
    // MARK: - Debug
    
#if DEBUG
    func makeDebugCoordinator(navigation: UINavigationController) -> DebugCoordinatingProtocol {
        container.debugImportCoordinator(navigation)
    }
#endif
}
