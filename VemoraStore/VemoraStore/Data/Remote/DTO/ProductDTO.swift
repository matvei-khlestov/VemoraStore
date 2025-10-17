//
//  ProductDTO.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import Foundation
import FirebaseCore

/// Data Transfer Object, описывающий товар (`ProductDTO`) в слое данных.
///
/// Назначение:
/// - используется для обмена данными между Firestore (или другим удалённым источником)
///   и локальными слоями приложения (Core Data, Domain);
/// - обеспечивает изоляцию сетевых моделей от бизнес-логики и UI.
///
/// Состав:
/// - `id`: уникальный идентификатор товара;
/// - `name`: название товара;
/// - `description`: текстовое описание;
/// - `nameLower`: название в нижнем регистре (для полнотекстового поиска);
/// - `categoryId`: идентификатор категории;
/// - `brandId`: идентификатор бренда;
/// - `price`: цена товара;
/// - `imageURL`: ссылка на изображение;
/// - `isActive`: флаг активности (отображается ли товар в каталоге);
/// - `createdAt`, `updatedAt`: даты создания и обновления;
/// - `keywords`: массив поисковых ключей.
///
/// Особенности реализации:
/// - метод `toEntity()` преобразует DTO в доменную модель `Product`;
/// - при преобразовании даты конвертируются в строку формата ISO 8601 для унификации хранения;
/// - используется при синхронизации данных каталога (`CatalogCollections`, `CoreDataCatalogStore`).

struct ProductDTO: Equatable {
    let id: String
    let name: String
    let description: String
    let nameLower: String
    let categoryId: String
    let brandId: String
    let price: Double
    let imageURL: String
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    let keywords: [String]
    
    func toEntity() -> Product {
        .init(
            id: id,
            name: name,
            description: description,
            nameLower: nameLower,
            categoryId: categoryId,
            brandId: brandId,
            price: price,
            imageURL: imageURL,
            isActive: isActive,
            createdAt: ISO8601DateFormatter().string(from: createdAt),
            updatedAt: ISO8601DateFormatter().string(from: updatedAt),
            keywords: keywords
        )
    }
}
