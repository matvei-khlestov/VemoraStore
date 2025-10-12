//
//  FavoriteDTO.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.10.2025.
//

import Foundation

struct FavoriteDTO: Equatable {
    let userId: String
    let productId: String
    let brandName: String
    let title: String
    let imageURL: String?
    let updatedAt: Date
    let price: Double
}

extension FavoriteDTO {
    func toEntity() -> FavoriteItem {
        .init(
            userId: userId,
            productId: productId,
            brandName: brandName,
            title: title,
            price: price,
            imageURL: imageURL,
            updatedAt: updatedAt
        )
    }
}
