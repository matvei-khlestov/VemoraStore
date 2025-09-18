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
            description: "…",
            price: 940,
            image: URL(string:"https://picsum.photos/seed/oslo/400/300")!,
            categoryId: "sofas",
            brendId: "vemora"
        )
        let p2 = Product(
            id: "chair_2",
            name: "Vemora Luton Chair",
            description: "…",
            price: 210,
            image: URL(string:"https://picsum.photos/seed/luton/400/300")!,
            categoryId: "chairs",
            brendId: "vemora"
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
