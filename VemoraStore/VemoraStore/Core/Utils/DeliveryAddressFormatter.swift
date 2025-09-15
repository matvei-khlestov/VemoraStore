//
//  DeliveryAddressFormatter.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import Foundation

struct DefaultDeliveryAddressFormatter: DeliveryAddressFormattingProtocol {
    func formatBaseAddress(_ baseAddress: String) -> [String] {
        let parts = baseAddress
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        
        let city   = parts.indices.contains(0) ? String(parts[0]) : ""
        let street = parts.indices.contains(1) ? String(parts[1]) : ""
        let house  = parts.indices.contains(2) ? String(parts[2]) : ""
        
        var chunks: [String] = []
        if !city.isEmpty   { chunks.append("г. \(city)") }
        if !street.isEmpty { chunks.append(street) }
        if !house.isEmpty  { chunks.append("д. \(house)") }
        
        return chunks
    }
}
