//
//  OrderItemDTO.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Foundation

struct OrderItemDTO: Equatable {
    let productId: String
    let brandName: String
    let title: String
    let price: Double
    let imageURL: String?
    let quantity: Int
}
