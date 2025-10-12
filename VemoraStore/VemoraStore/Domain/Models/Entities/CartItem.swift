//
//  CartItem.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 11.10.2025.
//

import Foundation

struct CartItem: Equatable, Hashable {
    let userId: String
    let productId: String
    var brandName: String
    var title: String
    var price: Double
    var imageURL: String?
    var quantity: Int
    var updatedAt: Date
    
    var lineTotal: Double { price * Double(quantity) }
}
