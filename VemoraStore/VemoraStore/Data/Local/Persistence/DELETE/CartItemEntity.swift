//
//  CartItemEntity.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation

struct CartItemEntity: Identifiable {
    let id: String
    let product: Product
    var quantity: Int
    
    var totalPrice: Double {
        Double(quantity) * product.price
    }
}

