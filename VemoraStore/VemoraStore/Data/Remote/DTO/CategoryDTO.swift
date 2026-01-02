//
//  CategoryDTO.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import Foundation
import FirebaseCore

/// Data Transfer Object, описывающий категорию товаров (`CategoryDTO`).
///
/// Назначение:
/// - служит промежуточной моделью между Firestore и доменной моделью `Category`;
/// - используется при синхронизации каталога в `CatalogCollections` и `CoreDataCatalogStore`;
/// - изолирует слой данных от бизнес-логики и UI.
///
/// Состав:
/// - `id`: уникальный идентификатор категории;
/// - `name`: название категории;
/// - `imageURL`: ссылка на изображение категории;
/// - `brandIds`: список идентификаторов брендов, связанных с категорией;
/// - `isActive`: флаг активности категории;
/// - `createdAt`, `updatedAt`: даты создания и последнего обновления.
///
/// Особенности реализации:
/// - метод `toEntity()` преобразует DTO в доменную модель `Category`;
/// - даты конвертируются в строковый формат ISO 8601 для унификации хранения;
/// - `Equatable` используется для корректной работы в Combine-пайплайнах и оптимизации сравнения данных.

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
