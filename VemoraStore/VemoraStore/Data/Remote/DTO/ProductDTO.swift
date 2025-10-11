//
//  ProductDTO.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import Foundation
import FirebaseCore

struct ProductDTO: Equatable {
    let id: String
    let name: String
    let description: String
    let nameLower: String
    let categoryId: String
    let brandId: String
    let price: Double
    let imageURL: String
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    let keywords: [String]
    
    func toEntity() -> Product {
        .init(
            id: id,
            name: name,
            description: description,
            nameLower: nameLower,
            categoryId: categoryId,
            brandId: brandId,
            price: price,
            imageURL: imageURL,
            isActive: isActive,
            createdAt: ISO8601DateFormatter().string(from: createdAt),
            updatedAt: ISO8601DateFormatter().string(from: updatedAt),
            keywords: keywords
        )
    }
}
