//
//  CategoryDTO+FirebaseMapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import Foundation
import FirebaseCore

extension CategoryDTO {
    static func fromFirebase(id: String, data: [String: Any]) -> CategoryDTO {
        let tsCreated = (data["createdAt"] as? Timestamp)?.dateValue() ?? .distantPast
        let tsUpdated = (data["updatedAt"] as? Timestamp)?.dateValue() ?? .distantPast
        return .init(
            id: id,
            name: data["name"] as? String ?? "",
            imageURL: data["imageURL"] as? String ?? "",
            brandIds: data["brandIds"] as? [String] ?? [],
            isActive: data["isActive"] as? Bool ?? true,
            createdAt: tsCreated,
            updatedAt: tsUpdated
        )
    }
}
