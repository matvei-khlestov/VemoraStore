//
//  ProductDTO+FirebaseMapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import Foundation
import FirebaseCore

/// Маппинг между `ProductDTO` и документами Firestore (`/products/{productId}`).
///
/// Назначение:
/// - преобразование данных Firestore в модель `ProductDTO` (`fromFirebase`);
/// - безопасное чтение и обработка всех полей с дефолтами.
///
/// Особенности реализации:
/// - даты `createdAt` и `updatedAt` восстанавливаются из `Timestamp`, при отсутствии — `.distantPast`;
/// - строковые поля (`name`, `description`, `categoryId`, `brandId`, `imageURL`) заполняются пустыми значениями при отсутствии данных;
/// - цена (`price`) приводится к `Double` и по умолчанию равна `0`;
/// - `isActive` интерпретируется как `true`, если поле отсутствует (для корректной фильтрации);
/// - поле `keywords` безопасно десериализуется как `[String]`, даже если тип в Firestore не соответствует.
///
/// Используется в:
/// - `CatalogCollections` для загрузки продуктов из Firestore;
/// - `CoreDataCatalogStore` для апсерта DTO в локальные сущности (`CDProduct`);
/// - фильтрах каталога (`CatalogFilterViewModel`) и поисковых сценариях.

extension ProductDTO {
    static func fromFirebase(id: String, data: [String: Any]) -> ProductDTO {
        let tsCreated = (data["createdAt"] as? Timestamp)?.dateValue() ?? .distantPast
        let tsUpdated = (data["updatedAt"] as? Timestamp)?.dateValue() ?? .distantPast
        return .init(
            id: id,
            name: data["name"] as? String ?? "",
            description: data["description"] as? String ?? "",
            nameLower: data["nameLower"] as? String ?? "",
            categoryId: data["categoryId"] as? String ?? "",
            brandId: data["brandId"] as? String ?? "",
            price: data["price"] as? Double ?? 0,
            imageURL: data["imageURL"] as? String ?? "",
            isActive: data["isActive"] as? Bool ?? true,
            createdAt: tsCreated,
            updatedAt: tsUpdated,
            keywords: data["keywords"] as? [String] ?? []
        )
    }
}
