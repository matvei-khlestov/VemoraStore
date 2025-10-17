//
//  BrandDTO.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 09.10.2025.
//

import Foundation
import FirebaseFirestore

/// Data Transfer Object, описывающий бренд (`BrandDTO`).
///
/// Назначение:
/// - используется для получения и синхронизации данных брендов из Firestore и Core Data;
/// - служит промежуточным слоем между удалённой базой и доменной моделью `Brand`;
/// - обеспечивает изоляцию слоя данных от бизнес-логики.
///
/// Состав:
/// - `id`: уникальный идентификатор бренда;
/// - `name`: наименование бренда;
/// - `imageURL`: ссылка на изображение бренда;
/// - `isActive`: флаг активности бренда (используется для фильтрации в каталоге);
/// - `createdAt`, `updatedAt`: временные метки создания и последнего обновления.
///
/// Особенности реализации:
/// - метод `toEntity()` преобразует DTO в доменную модель `Brand`;
/// - используется единый форматтер `ISO8601.shared` для конвертации дат в строковый формат;
/// - `Hashable` реализован для использования брендов в коллекциях и SwiftUI DiffableDataSource.

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
