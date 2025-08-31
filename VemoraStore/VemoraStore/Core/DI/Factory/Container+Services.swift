//
//  Container+Services.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import FactoryKit

extension Container {
    var authService: Factory<AuthServiceProtocol> {
        self { FirebaseAuthService() }.singleton
    }
    var productService: Factory<ProductServiceProtocol> {
        self { FirestoreProductService() }.singleton
    }
    var profileService: Factory<ProfileServiceProtocol> {
        self { FirebaseProfileService() }.singleton
    }
    var cartService: Factory<CartServiceProtocol> {
        self { CartService.shared }.singleton
    }
    var favoritesService: Factory<FavoritesServiceProtocol> {
        self { FavoritesService.shared }.singleton
    }
    var notificationService: Factory<NotificationServiceProtocol> {
        self { FirebaseNotificationService() }.singleton
    }
    var locationService: Factory<LocationServiceProtocol> {
        self { LocationService.shared }.singleton
    }
}
