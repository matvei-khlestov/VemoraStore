//
//  OrderDTO.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Foundation

/// Data Transfer Object, описывающий заказ (`OrderDTO`) между слоями данных и бизнес-логикой.
///
/// Назначение:
/// - хранение сериализуемых данных заказа, получаемых из Firestore или Core Data;
/// - передача между слоями Data / Domain без зависимостей от UI или фреймворков;
/// - преобразование в доменную модель (`OrderEntity`) для бизнес-операций.
///
/// Состав:
/// - `id`: идентификатор заказа;
/// - `userId`: идентификатор пользователя;
/// - `createdAt`, `updatedAt`: временные метки создания и обновления;
/// - `status`: текущий статус (`OrderStatus`);
/// - `receiveAddress`: адрес получения заказа;
/// - `paymentMethod`: способ оплаты;
/// - `comment`, `phoneE164`: необязательные комментарий и телефон в формате E.164;
/// - `items`: список позиций (`OrderItemDTO`).
///
/// Особенности реализации:
/// - конвертер `toEntity()` создаёт полную доменную сущность `OrderEntity` для использования в бизнес-логике;
/// - вложенные DTO преобразуются в `OrderItem` с созданием `Product` на основе данных позиции;
/// - используется при маппинге заказов из Firestore (`OrderDTO+FirebaseMapper`).

struct OrderDTO: Equatable {
    let id: String
    let userId: String
    let createdAt: Date
    let updatedAt: Date
    let status: OrderStatus
    let receiveAddress: String
    let paymentMethod: String
    let comment: String?
    let phoneE164: String?
    let items: [OrderItemDTO]
}

extension OrderDTO {
    func toEntity() -> OrderEntity {
        OrderEntity(
            id: id,
            userId: userId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            status: status,
            receiveAddress: receiveAddress,
            paymentMethod: paymentMethod,
            comment: comment ?? "",
            phoneE164: phoneE164,
            items: items.map { item in
                OrderItem(
                    product: Product(
                        id: item.productId,
                        name: item.title,
                        description: "",
                        nameLower: item.title.lowercased(),
                        categoryId: "",
                        brandId: item.brandName,
                        price: item.price,
                        imageURL: item.imageURL ?? "",
                        isActive: true,
                        createdAt: "",
                        updatedAt: "",
                        keywords: []
                    ),
                    quantity: item.quantity
                )
            }
        )
    }
}
