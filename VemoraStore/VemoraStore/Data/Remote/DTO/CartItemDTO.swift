//
//  CartItemDTO.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 11.10.2025.
//

import Foundation
import FirebaseCore

struct CartDTO: Equatable {
    let userId: String
    let productId: String
    let brandName: String
    let title: String
    let price: Double
    let imageURL: String?
    let quantity: Int
    let updatedAt: Date
}

extension CartDTO {
    func toEntity() -> CartItem {
        .init(
            userId: userId,
            productId: productId,
            brandName: brandName,
            title: title,
            price: price,
            imageURL: imageURL,
            quantity: quantity,
            updatedAt: updatedAt
        )
    }
}

