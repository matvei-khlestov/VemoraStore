//
//  CDFavoriteItem+Mapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.10.2025.
//

import Foundation

extension CDFavoriteItem {
    func apply(dto: FavoriteDTO) {
        userId = dto.userId
        productId = dto.productId
        brandName = dto.brandName
        title = dto.title
        imageURL = dto.imageURL
        updatedAt = dto.updatedAt
        price = dto.price
    }
}

extension FavoriteItem {
    init?(cd: CDFavoriteItem?) {
        guard let cd,
              let userId = cd.userId,
              let productId = cd.productId,
              let brandName = cd.brandName,
              let title = cd.title,
              let updatedAt = cd.updatedAt else { return nil }
        self.init(
            userId: userId,
            productId: productId,
            brandName: brandName,
            title: title,
            price: cd.price,
            imageURL: cd.imageURL,
            updatedAt: updatedAt
        )
    }
}
