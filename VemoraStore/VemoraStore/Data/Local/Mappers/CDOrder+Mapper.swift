//
//  CDOrder+Mapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Foundation
import CoreData

extension CDOrder {
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
        
        // replace items
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

extension OrderEntity {
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
        
        // 1) Явно приводим и копируем элементы, чтобы упростить типизацию
        let cdItemsSet: Set<CDOrderItem> = (cd.items as? Set<CDOrderItem>) ?? []
        let cdItems: [CDOrderItem] = Array(cdItemsSet)
        
        // 2) Сортируем в отдельном шаге
        let sortedCdItems: [CDOrderItem] = cdItems.sorted {
            let l = $0.productId ?? ""
            let r = $1.productId ?? ""
            return l < r
        }
        
        // 3) Маппим в доменную модель с явными типами
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
