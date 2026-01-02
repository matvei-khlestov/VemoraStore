//
//  CheckoutStorageMock.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import Foundation
@testable import VemoraStore

final class CheckoutStorageMock: CheckoutStoringProtocol {
    var savedDeliveryMethod: SavedDeliveryMethod = .pickup
    var savedDeliveryAddressString: String?
    var savedReceiverPhoneE164: String?
    
    private(set) var resetCalls = 0
    
    func reset() { resetCalls += 1 }
}
