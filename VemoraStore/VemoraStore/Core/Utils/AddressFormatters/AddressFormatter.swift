//
//  AddressFormatter.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.09.2025.
//

import Foundation
import MapKit

// MARK: - Default impl

struct DefaultAddressFormatter: AddressFormattingProtocol {
    func displayString(from placemark: MKPlacemark, fallback: String) -> String {
        let parts = [
            placemark.locality,
            placemark.thoroughfare,
            placemark.subThoroughfare
        ]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        
        let result = parts.joined(separator: ", ")
        return result.isEmpty ? fallback : result
    }
}
