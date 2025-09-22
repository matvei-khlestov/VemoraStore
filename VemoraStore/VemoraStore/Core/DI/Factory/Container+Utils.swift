//
//  Container+Utils.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import FactoryKit

extension Container {
    
    var addressFormatter: Factory<AddressFormattingProtocol> {
        self { DefaultAddressFormatter() }
    }
    
    var deliveryAddressFormatter: Factory<DeliveryAddressFormattingProtocol> {
        self { DefaultDeliveryAddressFormatter() }
    }
    
    var authValidator: Factory<AuthValidatingProtocol> {
        self { AuthValidator() }
    }
}
