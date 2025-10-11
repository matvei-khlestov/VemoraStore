//
//  BrandDTO.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 09.10.2025.
//

import Foundation
import FirebaseFirestore

struct BrandDTO: Hashable {
    let id: String
    let name: String
    let imageURL: String
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
}

extension BrandDTO {
    func toEntity() -> Brand {
        Brand(
            id: id,
            name: name,
            imageURL: imageURL,
            isActive: isActive,
            createdAt: ISO8601.shared.string(from: createdAt),
            updatedAt: ISO8601.shared.string(from: updatedAt)
        )
    }
}

private enum ISO8601 {
    static let shared: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
}
