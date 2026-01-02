//
//  CDCartItem+Mapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 11.10.2025.
//

import Foundation

/// Расширение `CDCartItem`, реализующее маппинг между Core Data и слоями DTO / Domain.
///
/// Основные задачи:
/// - Применение данных из `CartDTO` к Core Data сущности (`apply(dto:)`);
/// - Проверка совпадения Core Data записи с DTO (`matches(_:)`);
/// - Преобразование `CDCartItem` в доменную модель (`toCartItem()` и `CartItem.init(cd:)`).
///
/// Используется в:
/// - `CartLocalStore` и `CartRepository` для синхронизации, обновления и отображения данных корзины.
extension CDCartItem {
    
    /// Применяет данные из `CartDTO` к Core Data сущности.
    /// - Parameter dto: DTO корзины, полученный с сервера или из репозитория.
    func apply(dto: CartDTO) {
        userId = dto.userId
        productId = dto.productId
        brandName = dto.brandName
        title = dto.title
        price = dto.price
        imageURL = dto.imageURL
        quantity = Int32(dto.quantity)
        updatedAt = dto.updatedAt
    }
    
    /// Проверяет, совпадают ли значения текущей записи с указанным DTO.
    /// Используется для предотвращения лишних обновлений.
    /// - Parameter dto: DTO для сравнения.
    /// - Returns: `true`, если все поля совпадают.
    func matches(_ dto: CartDTO) -> Bool {
        (userId ?? "") == dto.userId &&
        (productId ?? "") == dto.productId &&
        (brandName ?? "") == dto.brandName &&
        (title ?? "") == dto.title &&
        price == dto.price &&
        (imageURL ?? "") == (dto.imageURL ?? "") &&
        Int(quantity) == dto.quantity &&
        (updatedAt ?? .distantPast) == dto.updatedAt
    }
}

/// Расширение `CartItem`, предоставляющее инициализацию из Core Data сущности `CDCartItem`.
///
/// Выполняет:
/// - безопасное извлечение данных и преобразование в доменную модель;
/// - fallback значений по умолчанию при отсутствии данных.
extension CartItem {
    
    /// Инициализация из Core Data сущности `CDCartItem`.
    /// - Parameter cd: Сущность корзины из Core Data.
    init?(cd: CDCartItem?) {
        guard let cd,
              let userId = cd.userId,
              let productId = cd.productId,
              let brandName = cd.brandName,
              let title = cd.title,
              let updatedAt = cd.updatedAt else { return nil }
        
        self.init(
            userId: userId,
            productId: productId,
            brandName: brandName,
            title: title,
            price: cd.price,
            imageURL: cd.imageURL,
            quantity: Int(cd.quantity),
            updatedAt: updatedAt
        )
    }
}

extension CDCartItem {
    
    /// Преобразует `CDCartItem` в доменную модель `CartItem`.
    /// Используется при реактивных обновлениях (`FRCPublisher`).
    func toCartItem() -> CartItem {
        CartItem(
            userId: userId ?? "",
            productId: productId ?? "",
            brandName: brandName ?? "",
            title: title ?? "",
            price: price,
            imageURL: imageURL,
            quantity: Int(quantity),
            updatedAt: updatedAt ?? Date()
        )
    }
}
