//
//  OrderDTO.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Foundation

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

// DTO → Entity
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
