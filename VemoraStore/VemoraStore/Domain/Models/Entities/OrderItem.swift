//
//  OrderItem.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Foundation

struct OrderItem: Equatable, Identifiable {
    var id: String { product.id }
    let product: Product
    let quantity: Int
    
    var lineTotal: Double { product.price * Double(quantity) }
}

