//
//  Container+Services.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import FactoryKit

extension Container {
    
    // MARK: - Auth
    
    var authSessionStorage: Factory<AuthSessionStoringProtocol> {
        self { AuthSessionStorage(keychain: self.keychainService()) }.singleton
    }
    
    var authService: Factory<AuthServiceProtocol> {
        self { FirebaseAuthService(session: self.authSessionStorage()) }.singleton
    }
    
    var passwordResetService: Factory<PasswordResetServiceProtocol> {
        self { FirebasePasswordResetService() }.singleton
    }
    
    // MARK: - Security
    
    var keychainService: Factory<KeychainServiceProtocol> {
        self { KeychainService() }.singleton
    }
    
    // MARK: - Profile
    
    var avatarStorageService: Factory<AvatarStorageServiceProtocol> {
        self { AvatarStorageService() }.singleton
    }

    // MARK: - Checkout
    
    var checkoutStorage: Factory<CheckoutStoringProtocol> {
        self { CheckoutStorage.shared }.singleton
    }
    
    // MARK: - Maps
    
    var addressSearchService: Factory<AddressSearchServiceProtocol> {
        self { AddressSearchService() }
    }
    
    var geocodingService: Factory<GeocodingServiceProtocol> {
        self { CLGeocodingService() }
    }
    
    // MARK: - Notifications
    
    var localNotificationService: Factory<LocalNotifyingProtocol> {
        self { LocalNotificationService.shared }.singleton
    }
    
    // MARK: - Debug
    
#if DEBUG
    var debugImportStorage: Factory<DebugImportStoringProtocol> {
        self { DebugImportStorage.shared }
    }
    
    var checksumStorage: ParameterFactory<String, ChecksumStoringProtocol> {
        self { namespace in
            ChecksumStorage(namespace: namespace)
        }
    }
    
    var debugImportService: Factory<DebugImportServicingProtocol> {
        self { [unowned self] in
            DebugImportService(
                checksumStoreFactory: { namespace in
                    self.checksumStorage(namespace)
                }
            )
        }.singleton
    }
    
    var debugImporter: Factory<DebugImportingProtocol> {
        self { [unowned self] in
            DebugImporter(
                debugImportService: self.debugImportService(),
                debugImportStorage: self.debugImportStorage()
            )
        }.singleton
    }
#endif
}
