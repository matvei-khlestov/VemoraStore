//
//  Order.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation

struct OrderItem: Codable, Hashable {
    let productId: String
    let name: String
    let price: Double
    let qty: Int
}


struct Order: Codable, Hashable {
    let id: String
    let items: [OrderItem]
    let total: Double
    let address: Address
    let deliveryType: String
    let status: String
}
