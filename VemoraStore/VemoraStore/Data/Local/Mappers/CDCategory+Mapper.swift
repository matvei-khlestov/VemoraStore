//
//  CDCategory+Mapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import CoreData

extension CDCategory {
    func apply(dto: CategoryDTO) {
        id = dto.id
        name = dto.name
        imageURL = dto.imageURL
        brandIds = dto.brandIds
        isActive = dto.isActive
        createdAt = dto.createdAt
        updatedAt = dto.updatedAt
    }
    
    func matches(_ dto: CategoryDTO) -> Bool {
        (id ?? "") == dto.id &&
        (name ?? "") == dto.name &&
        (imageURL ?? "") == dto.imageURL &&
        (brandIds ?? []) == dto.brandIds &&
        isActive == dto.isActive &&
        (createdAt ?? .distantPast) == dto.createdAt &&
        (updatedAt ?? .distantPast) == dto.updatedAt
    }
}

extension Category {
    init?(cd: CDCategory?) {
        guard
            let cd,
            let id = cd.id,
            let name = cd.name,
            let imageURL = cd.imageURL,
            let createdAt = cd.createdAt,
            let updatedAt = cd.updatedAt
        else { return nil }
        
        self.init(
            id: id,
            name: name,
            imageURL: imageURL,
            brandIds: cd.brandIds ?? [],
            isActive: cd.isActive,
            createdAt: ISO8601.shared.string(from: createdAt),
            updatedAt: ISO8601.shared.string(from: updatedAt)
        )
    }
}

// MARK: - Private helpers

private enum ISO8601 {
    static let shared: ISO8601DateFormatter = {
        ISO8601DateFormatter()
    }()
}
