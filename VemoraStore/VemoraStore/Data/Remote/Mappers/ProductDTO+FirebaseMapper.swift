//
//  ProductDTO+FirebaseMapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import Foundation
import FirebaseCore

extension ProductDTO {
    static func fromFirebase(id: String, data: [String: Any]) -> ProductDTO {
        let tsCreated = (data["createdAt"] as? Timestamp)?.dateValue() ?? .distantPast
        let tsUpdated = (data["updatedAt"] as? Timestamp)?.dateValue() ?? .distantPast
        return .init(
            id: id,
            name: data["name"] as? String ?? "",
            description: data["description"] as? String ?? "",
            nameLower: data["nameLower"] as? String ?? "",
            categoryId: data["categoryId"] as? String ?? "",
            brandId: data["brandId"] as? String ?? "",
            price: data["price"] as? Double ?? 0,
            imageURL: data["imageURL"] as? String ?? "",
            isActive: data["isActive"] as? Bool ?? true,
            createdAt: tsCreated,
            updatedAt: tsUpdated,
            keywords: data["keywords"] as? [String] ?? []
        )
    }
}
