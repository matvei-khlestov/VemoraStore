//
//  CartDTO.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 17.10.2025.
//

import Foundation
import FirebaseCore

/// Data Transfer Object, описывающий элемент корзины (`CartDTO`).
///
/// Назначение:
/// - используется для обмена данными между Firestore и локальным хранилищем (Core Data);
/// - изолирует сетевые структуры данных от доменных моделей и UI.
///
/// Состав:
/// - `userId`: идентификатор пользователя, владельца корзины;
/// - `productId`: идентификатор товара;
/// - `brandName`: название бренда;
/// - `title`: название товара;
/// - `price`: цена за единицу;
/// - `imageURL`: опциональная ссылка на изображение товара;
/// - `quantity`: количество товара в корзине;
/// - `updatedAt`: дата последнего изменения.
///
/// Особенности реализации:
/// - метод `toEntity()` преобразует DTO в доменную модель `CartItem`;
/// - используется в `CartCollection` (удалённое хранилище) и `CoreDataCartStore` (локальное);
/// - обеспечивает консистентное хранение и передачу данных корзины между слоями приложения.

struct CartDTO: Equatable {
    let userId: String
    let productId: String
    let brandName: String
    let title: String
    let price: Double
    let imageURL: String?
    let quantity: Int
    let updatedAt: Date
}

extension CartDTO {
    func toEntity() -> CartItem {
        .init(
            userId: userId,
            productId: productId,
            brandName: brandName,
            title: title,
            price: price,
            imageURL: imageURL,
            quantity: quantity,
            updatedAt: updatedAt
        )
    }
}


