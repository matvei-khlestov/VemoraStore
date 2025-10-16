//
//  OrdersRepositorySpy_Checkout.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import Foundation
import Combine
@testable import VemoraStore

struct ParsedArgs: Equatable {
    var userId: String
    var itemIds: [String]
    var isPickup: Bool
    var address: String?
    var phone: String?
    var comment: String?
}

final class OrdersRepositorySpy_Checkout: OrdersRepository {
    private let subject = CurrentValueSubject<[OrderEntity], Never>([])
    private(set) var createCalls = 0
    private(set) var lastDTO: OrderDTO?
    
    var parsed: ParsedArgs? {
        guard let d = lastDTO else { return nil }
        let raw = d.receiveAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = raw.lowercased()
        let isPickup =
        raw.isEmpty ||
        lower.contains("самовывоз") || 
        lower.contains("pickup")
        let ids = d.items.map { $0.productId }
        return .init(
            userId: d.userId,
            itemIds: ids,
            isPickup: isPickup,
            address: isPickup ? nil : d.receiveAddress,
            phone: d.phoneE164,
            comment: d.comment
        )
    }
    
    func observeOrders() -> AnyPublisher<[OrderEntity], Never> {
        subject.eraseToAnyPublisher()
    }
    
    func refresh(uid: String) async throws {}
    
    func create(order: OrderDTO) async throws {
        createCalls += 1
        lastDTO = order
    }
    
    func updateStatus(orderId: String, to status: OrderStatus) async throws {}
    
    func clear() async throws {}
}
