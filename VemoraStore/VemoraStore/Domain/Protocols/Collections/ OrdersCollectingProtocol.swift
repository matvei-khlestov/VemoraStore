//
//   OrdersCollectingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Foundation
import Combine

protocol OrdersCollectingProtocol: AnyObject {
    func fetchOrders(uid: String) async throws -> [OrderDTO]
    func createOrder(uid: String, dto: OrderDTO) async throws
    func updateStatus(uid: String, orderId: String, status: OrderStatus) async throws
    func listenOrders(uid: String) -> AnyPublisher<[OrderDTO], Never>
    func clear(uid: String) async throws
}
