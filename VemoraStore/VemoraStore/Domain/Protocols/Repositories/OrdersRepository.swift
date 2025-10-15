//
//  OrdersRepository.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Combine

protocol OrdersRepository: AnyObject {
    // Streams
    func observeOrders() -> AnyPublisher<[OrderEntity], Never>

    // Commands
    func refresh(uid: String) async throws
    func create(order: OrderDTO) async throws
    func updateStatus(orderId: String, to status: OrderStatus) async throws
    func clear() async throws
}
