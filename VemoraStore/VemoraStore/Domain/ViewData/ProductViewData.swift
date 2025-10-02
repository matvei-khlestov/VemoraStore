//
//  ProductViewData.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 28.09.2025.
//

import Foundation

struct ProductViewData: Hashable {
    let id: String
    let title: String
    let priceText: String
    let details: String
    let imageURL: URL?
    let isFavorite: Bool
    let isInCart: Bool
}

extension ProductTest {
    func viewData(
        isFavorite: Bool,
        isInCart: Bool
    ) -> ProductViewData {
        .init(
            id: id,
            title: name,
            priceText: String(format: "$%.2f", price),
            details: description,
            imageURL: image,
            isFavorite: isFavorite,
            isInCart: isInCart
        )
    }
}
