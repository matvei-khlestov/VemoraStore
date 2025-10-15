//
//  KeychainKey.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 02.10.2025.
//

import Foundation

/// Ключи для хранения в Keychain.
/// Для произвольных ключей используй `.custom("some.key")`.
enum KeychainKey: Hashable {
    case userId
    case authProvider
    case fcmToken
    case receiverPhoneE164
    case deliveryAddress
    case custom(String)
    
    var rawValue: String {
        switch self {
        case .userId:
            return "auth.userId"
        case .authProvider:
            return "auth.provider"
        case .fcmToken:
            return "notifications.fcmToken"
        case .receiverPhoneE164:
            return "checkout.receiverPhoneE164"
        case .deliveryAddress:
            return "checkout.deliveryAddress"
        case .custom(let key):
            return key
        }
    }
}
