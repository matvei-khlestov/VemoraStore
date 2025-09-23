//
//  Container+Services.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import FactoryKit

extension Container {
    
    // MARK: - Auth
    
    var authService: Factory<AuthServiceProtocol> {
        self { FirebaseAuthService() }.singleton
    }
    
    var passwordResetService: Factory<PasswordResetServiceProtocol> {
        self { FirebasePasswordResetService() }.singleton
    }
    
    // MARK: - Catalog
    
    var productService: Factory<ProductServiceProtocol> {
        self { FirestoreProductService() }.singleton
    }
    
    var favoritesService: Factory<FavoritesServiceProtocol> {
        self { FavoritesService.shared }.singleton
    }
    
    // MARK: - Profile
    
    var profileService: Factory<ProfileServiceProtocol> {
        self { FirebaseProfileService() }.singleton
    }
    
    var avatarStorageService: Factory<AvatarStorageServiceProtocol> {
        self { AvatarStorageService() }.singleton
    }
    
    // MARK: - Cart
    
    var cartService: Factory<CartServiceProtocol> {
        self { CartService.shared }.singleton
    }
    
    // MARK: - Notifications
    
    var notificationService: Factory<NotificationServiceProtocol> {
        self { FirebaseNotificationService() }.singleton
    }
    
    // MARK: - Maps
    
    var addressSearchService: Factory<AddressSearchServiceProtocol> {
        self { AddressSearchService() }
    }
    
    var geocodingService: Factory<GeocodingServiceProtocol> {
        self { CLGeocodingService() }
    }
    
    // MARK: - Orders
    
    var ordersService: Factory<OrdersServiceProtocol> {
        self { OrdersService() }
    }
}
