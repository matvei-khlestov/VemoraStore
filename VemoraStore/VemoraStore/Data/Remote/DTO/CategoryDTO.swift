//
//  CategoryDTO.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import Foundation
import FirebaseCore

struct CategoryDTO: Equatable {
    let id: String
    let name: String
    let imageURL: String
    let brandIds: [String]
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    func toEntity() -> Category {
        .init(
            id: id,
            name: name,
            imageURL: imageURL,
            brandIds: brandIds,
            isActive: isActive,
            createdAt: ISO8601DateFormatter().string(from: createdAt),
            updatedAt: ISO8601DateFormatter().string(from: updatedAt)
        )
    }
}
