//
//  AddressFormattingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.09.2025.
//

import Foundation
import MapKit

protocol AddressFormattingProtocol {
    func displayString(from placemark: MKPlacemark, fallback: String) -> String
}
