//
//  CategoryDTO+FirebaseMapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import Foundation
import FirebaseCore

/// Маппинг между `CategoryDTO` и документами Firestore (`/categories/{categoryId}`).
///
/// Назначение:
/// - преобразование данных Firestore в модель `CategoryDTO` (`fromFirebase`);
/// - корректная обработка отсутствующих или неполных данных с дефолтными значениями.
///
/// Особенности реализации:
/// - поля `createdAt` и `updatedAt` преобразуются из `Timestamp` в `Date`;
/// - при отсутствии имени категории поле `name` получает пустую строку;
/// - `brandIds` безопасно десериализуется как `[String]`, даже при несовпадении типов в Firestore;
/// - `isActive` по умолчанию устанавливается в `true`, чтобы категория считалась видимой.
///
/// Используется в:
/// - `CatalogCollections` при загрузке категорий из Firestore;
/// - `CoreDataCatalogStore` при апсерте DTO в локальные объекты (`CDCategory`).

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
