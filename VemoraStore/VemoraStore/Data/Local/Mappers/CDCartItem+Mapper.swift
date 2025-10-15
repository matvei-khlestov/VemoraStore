//
//  CDCartItem+Mapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 11.10.2025.
//

import Foundation

extension CDCartItem {
    func apply(dto: CartDTO) {
        userId = dto.userId
        productId = dto.productId
        brandName = dto.brandName
        title = dto.title
        price = dto.price
        imageURL = dto.imageURL
        quantity = Int32(dto.quantity)
        updatedAt = dto.updatedAt
    }
    
    func matches(_ dto: CartDTO) -> Bool {
        (userId ?? "") == dto.userId &&
        (productId ?? "") == dto.productId &&
        (brandName ?? "") == dto.brandName &&
        (title ?? "") == dto.title &&
        price == dto.price &&
        (imageURL ?? "") == (dto.imageURL ?? "") &&
        Int(quantity) == dto.quantity &&
        (updatedAt ?? .distantPast) == dto.updatedAt
    }
}

extension CartItem {
    init?(cd: CDCartItem?) {
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
            quantity: Int(cd.quantity),
            updatedAt: updatedAt
        )
    }
}

extension CDCartItem {
    func toCartItem() -> CartItem {
        CartItem(
            userId: userId ?? "",
            productId: productId ?? "",
            brandName: brandName ?? "",
            title: title ?? "",
            price: price,                         // Double в Core Data
            imageURL: imageURL,                   // String? ок
            quantity: Int(quantity),              // Int32 -> Int
            updatedAt: updatedAt ?? Date()
        )
    }
}
