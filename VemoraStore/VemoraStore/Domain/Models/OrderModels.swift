//
//  OrderModels.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 18.09.2025.
//

import Foundation

// MARK: - Статус заказа
enum OrderStatus: String {
    case assembling = "На сборке"
    case ready      = "Готов к выдаче"
    case delivering = "В доставке"
    case delivered  = "Доставлен"
    case cancelled  = "Отменён"
    
    var badgeText: String { rawValue }
}

// MARK: - Позиция заказа
struct OrderItem {
    /// Товар (из каталога)
    let product: ProductTest
    /// Количество единиц товара
    let quantity: Int
}

// MARK: - Заказ
struct OrderEntity {
    /// Уникальный идентификатор заказа
    let id: String
    /// Дата создания заказа
    let createdAt: Date
    /// Адрес получения или доставки
    let receiveAddress: String
    /// Способ оплаты (в текущей логике — только "При получении")
    let paymentMethod: String
    /// Текущий статус заказа
    let status: OrderStatus
    /// Список товаров в заказе
    let items: [OrderItem]
}
