//
//  OrdersRepositorySpy_Orders.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import Foundation
import Combine
@testable import VemoraStore

final class OrdersRepositorySpy_Orders: OrdersRepository {
    private let subject = CurrentValueSubject<[OrderEntity], Never>([])
    func observeOrders() -> AnyPublisher<[OrderEntity], Never> {
        subject.eraseToAnyPublisher()
    }
    func send(_ orders: [OrderEntity]) { subject.send(orders) }
    func refresh(uid: String) async throws {}
    func create(order: OrderDTO) async throws {}
    func updateStatus(orderId: String, to status: OrderStatus) async throws {}
    func clear() async throws {}
}
