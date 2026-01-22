//
//  OrdersRepositorySpy_Checkout.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import Foundation
import Combine
@testable import VemoraStore

final class OrdersRepositorySpy_Checkout: OrdersRepository {
    
    // MARK: - OrdersRepository (required)
    
    private let subject = CurrentValueSubject<[OrderEntity], Never>([])
    
    func observeOrders() -> AnyPublisher<[OrderEntity], Never> {
        subject.eraseToAnyPublisher()
    }
    
    func refresh(uid: String) async throws {}
    func create(order: OrderDTO) async throws {}
    func updateStatus(orderId: String, to status: OrderStatus) async throws {}
    func clear() async throws {}
    
    // MARK: - Checkout Spy API
    
    struct Parsed {
        let userId: String
        let itemIds: [String]
        let isPickup: Bool
        let address: String?
        let phone: String?
        let comment: String?
    }
    
    private(set) var createCalls: Int = 0
    private(set) var parsed: Parsed?
    
    var stubbedOrderId: String = "order-1"
    var stubbedCreateError: Error? = nil
    
    // ВАЖНО:
    // Этот метод должен совпадать по сигнатуре с тем, что вызывает CheckoutViewModel.
    // Даже если он определён в extension OrdersRepository где-то в продакшн-коде,
    // спай может иметь его напрямую — тестам это ок.
    func createOrderFromCheckout(
        userId: String,
        items: [CartItem],
        deliveryMethod: CheckoutViewModel.DeliveryMethod,
        addressString: String?,
        phoneE164: String?,
        comment: String?
    ) async throws -> String {
        createCalls += 1
        
        parsed = Parsed(
            userId: userId,
            itemIds: items.map(\.productId),
            isPickup: deliveryMethod == .pickup,
            address: addressString,
            phone: phoneE164,
            comment: comment
        )
        
        if let stubbedCreateError {
            throw stubbedCreateError
        }
        
        return stubbedOrderId
    }
}
