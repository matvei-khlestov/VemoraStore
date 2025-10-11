//
//  BrandDTO+FirebaseMapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 09.10.2025.
//

import Foundation
import FirebaseCore

extension BrandDTO {
    static func fromFirebase(id: String, data: [String: Any]) -> BrandDTO {
        BrandDTO(
            id: id,
            name: data["name"] as? String ?? id,
            imageURL: data["imageURL"] as? String ?? "",
            isActive: data["isActive"] as? Bool ?? true,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? .distantPast,
            updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue() ?? .distantPast
        )
    }
}
