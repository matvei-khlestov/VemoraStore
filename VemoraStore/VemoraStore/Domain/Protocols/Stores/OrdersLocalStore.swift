//
//  OrdersLocalStore.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Combine

protocol OrdersLocalStore: AnyObject {
    func observeOrders(userId: String) -> AnyPublisher<[OrderEntity], Never>
    func replaceAll(userId: String, with dtos: [OrderDTO])
    func upsert(userId: String, dto: OrderDTO)
    func updateStatus(userId: String, orderId: String, status: OrderStatus)
    func clear(userId: String)
}
