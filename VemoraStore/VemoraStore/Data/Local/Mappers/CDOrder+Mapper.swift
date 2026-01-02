//
//  CDOrder+Mapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Foundation
import CoreData

/// Расширение `CDOrder`, обеспечивающее маппинг между Core Data и DTO/Entity слоями.
///
/// Содержит:
/// - `apply(dto:ctx:)` — применение данных из `OrderDTO` к Core Data объекту;
/// - `OrderEntity.init(cd:)` — преобразование Core Data сущности в доменную модель `OrderEntity`.
///
/// Используется в:
/// - `OrdersLocalStore` — для сохранения заказов в базу и их чтения в доменную модель.
extension CDOrder {
    
    /// Применяет данные из `OrderDTO` к Core Data сущности `CDOrder`.
    /// - Parameters:
    ///   - dto: DTO заказа, полученный с сервера или из репозитория.
    ///   - ctx: Контекст `NSManagedObjectContext`, в котором выполняется обновление.
    func apply(dto: OrderDTO, ctx: NSManagedObjectContext) {
        id = dto.id
        userId = dto.userId
        createdAt = dto.createdAt
        updatedAt = dto.updatedAt
        status = dto.status.rawValue
        receiveAddress = dto.receiveAddress
        paymentMethod = dto.paymentMethod
        comment = dto.comment
        phoneE164 = dto.phoneE164
        
        // Удаляем старые товары и создаём новые из DTO
        let existingItems = (items as? Set<CDOrderItem>) ?? []
        existingItems.forEach { ctx.delete($0) }
        
        let mapped: [CDOrderItem] = dto.items.map { it in
            let e = CDOrderItem(context: ctx)
            e.productId = it.productId
            e.brandName = it.brandName
            e.title = it.title
            e.price = it.price
            e.imageURL = it.imageURL
            e.quantity = Int32(it.quantity)
            e.order = self
            return e
        }
        items = NSSet(array: mapped)
    }
}

/// Расширение `OrderEntity`, предоставляющее инициализацию из `CDOrder`.
///
/// Выполняет:
/// - безопасное извлечение и валидацию данных из Core Data сущности;
/// - преобразование `CDOrderItem` → `OrderItem`;
/// - сортировку элементов по `productId` для стабильного отображения;
/// - построение итоговой доменной сущности `OrderEntity`.
extension OrderEntity {
    
    /// Инициализирует `OrderEntity` из Core Data сущности `CDOrder`.
    /// - Parameter cd: Объект `CDOrder` из Core Data.
    init?(cd: CDOrder?) {
        guard
            let cd,
            let id = cd.id,
            let uid = cd.userId,
            let created = cd.createdAt,
            let statusRaw = cd.status,
            let status = OrderStatus(rawValue: statusRaw),
            let payment = cd.paymentMethod,
            let address = cd.receiveAddress
        else { return nil }
        
        // Приводим набор позиций заказа к массиву
        let cdItemsSet: Set<CDOrderItem> = (cd.items as? Set<CDOrderItem>) ?? []
        let cdItems: [CDOrderItem] = Array(cdItemsSet)
        
        // Стабильная сортировка по productId
        let sortedCdItems: [CDOrderItem] = cdItems.sorted {
            let l = $0.productId ?? ""
            let r = $1.productId ?? ""
            return l < r
        }
        
        // Преобразуем CDOrderItem → OrderItem с вложенным Product
        let items: [OrderItem] = sortedCdItems.map { ci in
            let prod = Product(
                id: ci.productId ?? "",
                name: ci.title ?? "",
                description: "",
                nameLower: (ci.title ?? "").lowercased(),
                categoryId: "",
                brandId: ci.brandName ?? "",
                price: ci.price,
                imageURL: ci.imageURL ?? "",
                isActive: true,
                createdAt: "",
                updatedAt: "",
                keywords: []
            )
            return OrderItem(product: prod, quantity: Int(ci.quantity))
        }
        
        self.init(
            id: id,
            userId: uid,
            createdAt: created,
            updatedAt: cd.updatedAt ?? created,
            status: status,
            receiveAddress: address,
            paymentMethod: payment,
            comment: cd.comment ?? "",
            phoneE164: cd.phoneE164,
            items: items
        )
    }
}
