//
//  Container+Coordinators.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import Foundation
import FactoryKit
import UIKit

extension Container {
    
    // MARK: - Catalog
    
    var catalogCoordinator: ParameterFactory<UINavigationController, CatalogCoordinatingProtocol> {
        self { navigation in
            CatalogCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory(),
                coordinatorFactory: self.coordinatorFactory()
            )
        }
    }
    
    // MARK: - Product Details
    
    var productDetailsCoordinator: ParameterFactory<(UINavigationController, Product), ProductDetailsCoordinatingProtocol> {
        self { navigation, product in
            ProductDetailsCoordinator(
                navigation: navigation,
                product: product,
                viewModelFactory: self.viewModelFactory(),
                coordinatorFactory: self.coordinatorFactory()
            )
        }
    }
    
    // MARK: - Map Picker
    
    var mapPickerCoordinator: ParameterFactory<UINavigationController, MapPickerCoordinatingProtocol> {
        self { nav in
            MapPickerCoordinator(
                navigation: nav,
                viewModelFactory: self.viewModelFactory()
            )
        }
    }
    
    // MARK: - Checkout
    
    var checkoutCoordinator: ParameterFactory<UINavigationController, CheckoutCoordinatingProtocol> {
        self { navigation in
            CheckoutCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory(),
                coordinatorFactory: self.coordinatorFactory()
            )
        }
    }
    
    // MARK: - Order Success
    
    var orderSuccessCoordinator: ParameterFactory<UINavigationController, OrderSuccessCoordinatingProtocol> {
        self { navigation in
            OrderSuccessCoordinator(navigation: navigation)
        }
    }
    
    // MARK: - Favorites
    
    var favoritesCoordinator: ParameterFactory<UINavigationController, FavoritesCoordinatingProtocol> {
        self { navigation in
            FavoritesCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory(),
                coordinatorFactory: self.coordinatorFactory()
            )
        }
    }

    // MARK: - Cart
    
    var cartCoordinator: ParameterFactory<UINavigationController, CartCoordinatingProtocol> {
        self { navigation in
            CartCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory(),
                coordinatorFactory: self.coordinatorFactory()
            )
        }
    }

    // MARK: - Orders
    
    var ordersCoordinator: ParameterFactory<UINavigationController, OrdersCoordinatingProtocol> {
        self { navigation in
            OrdersCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory()
            )
        }
    }
    
    // MARK: - About
    
    var aboutCoordinator: ParameterFactory<UINavigationController, AboutCoordinatingProtocol> {
        self { navigation in
            AboutCoordinator(navigation: navigation)
        }
    }

    // MARK: - Privacy Policy
    
    var privacyPolicyCoordinator: ParameterFactory<UINavigationController, PrivacyPolicyCoordinatingProtocol> {
        self { navigation in
            PrivacyPolicyCoordinator(navigation: navigation)
        }
    }

    // MARK: - Contact Us
    
    var contactUsCoordinator: ParameterFactory<UINavigationController, ContactUsCoordinatingProtocol> {
        self { navigation in
            ContactUsCoordinator(navigation: navigation)
        }
    }

    // MARK: - Reset Password
    
    var resetPasswordCoordinator: ParameterFactory<UINavigationController, ResetPasswordCoordinatingProtocol> {
        self { navigation in
            ResetPasswordCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory()
            )
        }
    }

    // MARK: - Auth
    
    var authCoordinator: ParameterFactory<UINavigationController, AuthCoordinatingProtocol> {
        self { navigation in
            AuthCoordinator(
                navigation: navigation,
                authService: self.authService(),
                viewModelFactory: self.viewModelFactory(),
                coordinatorFactory: self.coordinatorFactory()
            )
        }
    }

    // MARK: - Profile Guest
    
    var profileGuestCoordinator: ParameterFactory<UINavigationController, ProfileGuestCoordinatingProtocol> {
        self { navigation in
            ProfileGuestCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory(),
                coordinatorFactory: self.coordinatorFactory()
            )
        }
    }

    // MARK: - Profile User
    
    var profileUserCoordinator: ParameterFactory<UINavigationController, ProfileUserCoordinatingProtocol> {
        self { navigation in
            ProfileUserCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory(),
                coordinatorFactory: self.coordinatorFactory()
            )
        }
    }

    // MARK: - Edit Profile

    var editProfileCoordinator: ParameterFactory<UINavigationController, EditProfileCoordinatingProtocol> {
        self { navigation in
            EditProfileCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory(),
                coordinatorFactory: self.coordinatorFactory()
            )
        }
    }

    // MARK: - Edit Name

    var editNameCoordinator: ParameterFactory<UINavigationController, EditNameCoordinatingProtocol> {
        self { navigation in
            EditNameCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory()
            )
        }
    }

    // MARK: - Edit Email

    var editEmailCoordinator: ParameterFactory<UINavigationController, EditEmailCoordinatingProtocol> {
        self { navigation in
            EditEmailCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory()
            )
        }
    }

    // MARK: - Edit Phone

    var editPhoneCoordinator: ParameterFactory<UINavigationController, EditPhoneCoordinatingProtocol> {
        self { navigation in
            EditPhoneCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory()
            )
        }
    }

    // MARK: - Main
    
    var mainCoordinator: ParameterFactory<UINavigationController, MainCoordinatingProtocol> {
        self { navigation in
            MainCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory(),
                coordinatorFactory: self.coordinatorFactory()
            )
        }
    }

    // MARK: - App
    
    var appCoordinator: ParameterFactory<UINavigationController, AppCoordinatingProtocol> {
        self { navigation in
            AppCoordinator(
                navigation: navigation,
                authService: self.authService(),
                coordinatorFactory: self.coordinatorFactory()
            )
        }
    }
}
