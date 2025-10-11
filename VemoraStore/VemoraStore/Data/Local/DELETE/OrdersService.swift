//
//  OrdersService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 18.09.2025.
//

import Foundation

// MARK: - Stub service

final class OrdersService: OrdersServiceProtocol {
    func fetchOrders() -> [OrderEntity] {
        // Моки для примера
        let p1 = Product(
            id: "sofa_1",
            name: "Vemora Oslo Sofa 3-Seater",
            description: "Элегантный трёхместный диван с мягкой обивкой и прочным каркасом. Подходит для гостиной или кабинета.",
            nameLower: "vemora oslo sofa 3-seater",
            categoryId: "sofas",
            brandId: "vemora",
            price: 940,
            imageURL: "https://picsum.photos/seed/oslo/400/300",
            isActive: true,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            keywords: ["диван", "oslo", "vemora", "гостиная", "трехместный"]
        )

        let p2 = Product(
            id: "chair_2",
            name: "Vemora Luton Chair",
            description: "Удобный стул в скандинавском стиле, выполнен из натурального дерева и ткани. Отлично подойдёт для кухни или офиса.",
            nameLower: "vemora luton chair",
            categoryId: "chairs",
            brandId: "vemora",
            price: 210,
            imageURL: "https://picsum.photos/seed/luton/400/300",
            isActive: true,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: ISO8601DateFormatter().string(from: Date()),
            keywords: ["стул", "luton", "vemora", "кухня", "офис", "мебель"]
        )
        
        return [
            OrderEntity(
                id: "VMR-2025-0001",
                createdAt: Date().addingTimeInterval(-60*60*24*2),
                receiveAddress: "Москва, Ходынский б-р, 4",
                paymentMethod: "При получении",
                status: .assembling,
                items: [
                    .init(product: p1, quantity: 1),
                    .init(product: p2, quantity: 2)
                ]
            ),
            OrderEntity(
                id: "VMR-2025-0002",
                createdAt: Date().addingTimeInterval(-60*60*24*6),
                receiveAddress: "Москва, Тверская, 10",
                paymentMethod: "При получении",
                status: .delivering,
                items: [
                    .init(product: p2, quantity: 4)
                ]
            )
        ]
    }
}
