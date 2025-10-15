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
    
    var formValidator: Factory<FormValidatingProtocol> {
        self { FormValidator() }
    }
    
    var phoneFormatter: Factory<PhoneFormattingProtocol> {
        self { PhoneFormatter() }
    }
    
    var priceFormatter: Factory<PriceFormattingProtocol> {
        self { PriceFormatter() }
    }
}
