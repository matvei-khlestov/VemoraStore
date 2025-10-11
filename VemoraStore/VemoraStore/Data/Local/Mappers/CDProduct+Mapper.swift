//
//  CDProduct+Mapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import CoreData

extension CDProduct {
    func apply(dto: ProductDTO) {
        id         = dto.id
        name       = dto.name
        desc       = dto.description
        nameLower  = dto.nameLower
        categoryId = dto.categoryId
        brandId    = dto.brandId
        price      = dto.price
        imageURL   = dto.imageURL
        isActive   = dto.isActive
        createdAt  = dto.createdAt
        updatedAt  = dto.updatedAt
        keywords   = dto.keywords

        // Опционально: индекс для поиска (имя + ключевые слова в нижнем регистре)
        keywordsIndex = ([dto.nameLower] + dto.keywords.map { $0.lowercased() })
            .joined(separator: " ")
    }

    func matches(_ dto: ProductDTO) -> Bool {
        (id ?? "") == dto.id &&
        (name ?? "") == dto.name &&
        (desc ?? "") == dto.description &&
        (nameLower ?? "") == dto.nameLower &&
        (categoryId ?? "") == dto.categoryId &&
        (brandId ?? "") == dto.brandId &&
        price == dto.price &&
        (imageURL ?? "") == dto.imageURL &&
        isActive == dto.isActive &&
        (createdAt ?? .distantPast) == dto.createdAt &&
        (updatedAt ?? .distantPast) == dto.updatedAt &&
        (keywords ?? []) == dto.keywords &&
        (keywordsIndex ?? "") == (([dto.nameLower] + dto.keywords.map {
            $0.lowercased()
        }).joined(separator: " "))
    }
}

extension Product {
    init?(cd: CDProduct?) {
        guard let cd,
              let id = cd.id,
              let name = cd.name,
              let desc = cd.desc,
              let nameLower = cd.nameLower,
              let categoryId = cd.categoryId,
              let brandId = cd.brandId,
              let imageURL = cd.imageURL,
              let createdAt = cd.createdAt,
              let updatedAt = cd.updatedAt
        else { return nil }

        self.init(
            id: id,
            name: name,
            description: desc,
            nameLower: nameLower,
            categoryId: categoryId,
            brandId: brandId,
            price: cd.price,
            imageURL: imageURL,
            isActive: cd.isActive,
            createdAt: ISO8601.shared.string(from: createdAt),
            updatedAt: ISO8601.shared.string(from: updatedAt),
            keywords: cd.keywords ?? []
        )
    }
}

// MARK: - Private helpers

private enum ISO8601 {
    static let shared: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        return f
    }()
}
