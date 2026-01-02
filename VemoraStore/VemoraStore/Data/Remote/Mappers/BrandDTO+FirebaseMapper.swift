//
//  BrandDTO+FirebaseMapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 09.10.2025.
//

import Foundation
import FirebaseCore

/// Маппинг между `BrandDTO` и документами Firestore (`/brands/{brandId}`).
///
/// Назначение:
/// - преобразование данных Firestore в модель `BrandDTO` (`fromFirebase`);
/// - обеспечение безопасного чтения полей с дефолтными значениями при отсутствии данных.
///
/// Особенности реализации:
/// - дата создания и обновления (`createdAt`, `updatedAt`) восстанавливаются из `Timestamp`;
/// - при отсутствии имени бренд получает в качестве `name` значение `id`;
/// - поле `isActive` по умолчанию считается `true`, чтобы исключить деактивацию при неполных данных;
/// - корректно обрабатывает пустые или отсутствующие значения `imageURL`.
///
/// Используется в:
/// - `CatalogCollections` для загрузки брендов из Firestore;
/// - `CoreDataCatalogStore` при маппинге DTO в локальные сущности (`CDBrand`).

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
