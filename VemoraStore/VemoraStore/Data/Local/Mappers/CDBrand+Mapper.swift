//
//  CDBrand+Mapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 09.10.2025.
//

import CoreData
import Foundation

extension CDBrand {
    /// Применить данные из DTO к Core Data объекту
    func apply(dto: BrandDTO) {
        id        = dto.id
        name      = dto.name
        imageURL  = dto.imageURL
        isActive  = dto.isActive
        createdAt = dto.createdAt
        updatedAt = dto.updatedAt
    }

    /// Полное сравнение для экономии апдейтов
    func matches(_ dto: BrandDTO) -> Bool {
        (id ?? "") == dto.id &&
        (name ?? "") == dto.name &&
        (imageURL ?? "") == dto.imageURL &&
        isActive == dto.isActive &&
        (createdAt ?? .distantPast) == dto.createdAt &&
        (updatedAt ?? .distantPast) == dto.updatedAt
    }
}

extension Brand {
    /// Инициализация доменной модели из Core Data сущности
    init?(cd: CDBrand?) {
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
            isActive: cd.isActive,
            createdAt: ISO8601.shared.string(from: createdAt),
            updatedAt: ISO8601.shared.string(from: updatedAt)
        )
    }
}

// MARK: - Private helpers

private enum ISO8601 {
    static let shared: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        // В проекте используем интернет-формат с долями секунды
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
}
