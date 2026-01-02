//
//  FavoriteDTO.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.10.2025.
//

import Foundation

/// Data Transfer Object, описывающий элемент избранного (`FavoriteDTO`) пользователя.
///
/// Назначение:
/// - используется для синхронизации данных между Firestore и локальным хранилищем (Core Data);
/// - отделяет слой данных от бизнес-логики и UI.
///
/// Состав:
/// - `userId`: идентификатор пользователя, владельца списка избранного;
/// - `productId`: идентификатор товара;
/// - `brandName`: название бренда;
/// - `title`: название товара;
/// - `imageURL`: опциональная ссылка на изображение;
/// - `updatedAt`: дата последнего обновления;
/// - `price`: цена товара.
///
/// Особенности реализации:
/// - метод `toEntity()` преобразует DTO в доменную модель `FavoriteItem`;
/// - используется в `FavoritesCollection` (удалённое хранилище) и `CoreDataFavoritesStore` (локальное хранилище);
/// - обеспечивает надёжную передачу и кэширование состояния избранного пользователя.

struct FavoriteDTO: Equatable {
    let userId: String
    let productId: String
    let brandName: String
    let title: String
    let imageURL: String?
    let updatedAt: Date
    let price: Double
}

extension FavoriteDTO {
    func toEntity() -> FavoriteItem {
        .init(
            userId: userId,
            productId: productId,
            brandName: brandName,
            title: title,
            price: price,
            imageURL: imageURL,
            updatedAt: updatedAt
        )
    }
}
