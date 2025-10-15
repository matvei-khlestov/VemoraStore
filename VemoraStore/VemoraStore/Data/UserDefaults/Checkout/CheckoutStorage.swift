//
//  CheckoutStorage.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Foundation

final class CheckoutStorage: CheckoutStoringProtocol {

    static let shared = CheckoutStorage()
    
    private enum DKeys {
        static let deliveryMethod = "checkout.deliveryMethod"
    }
    
    private let prefs: PreferencesStore
    private let secrets: SecretsStore
    
    private init(prefs: PreferencesStore = DefaultsStore(),
                 secrets: SecretsStore = KeychainStore()) {
        self.prefs = prefs
        self.secrets = secrets
    }
    
    // MARK: - CheckoutStoringProtocol
    
    var savedDeliveryMethod: SavedDeliveryMethod {
        get {
            SavedDeliveryMethod(rawValue: prefs.string(forKey: DKeys.deliveryMethod) ?? "") ?? .pickup
        }
        set {
            prefs.set(newValue.rawValue, forKey: DKeys.deliveryMethod)
        }
    }
    
    var savedDeliveryAddressString: String? {
        get { secrets.get(.deliveryAddress) }
        set {
            guard let value = newValue, !value.isEmpty else {
                _ = secrets.remove(.deliveryAddress)
                return
            }
            _ = secrets.set(value, for: .deliveryAddress)
        }
    }
    
    var savedReceiverPhoneE164: String? {
        get { secrets.get(.receiverPhoneE164) }
        set {
            guard let value = newValue, !value.isEmpty else {
                _ = secrets.remove(.receiverPhoneE164)
                return
            }
            _ = secrets.set(value, for: .receiverPhoneE164)
        }
    }
    
    func reset() {
        prefs.remove(DKeys.deliveryMethod)
        _ = secrets.remove(.deliveryAddress)
        _ = secrets.remove(.receiverPhoneE164)
    }
}
