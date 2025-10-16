//
//  CartRepositoryMock.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import Foundation
import Combine
@testable import VemoraStore

final class CartRepositoryMock: CartRepository {

    // Streams
    let itemsSubject  = CurrentValueSubject<[CartItem], Never>([])
    let totalsSubject = CurrentValueSubject<(count: Int, price: Double), Never>((0, 0))

    // Tracking
    private(set) var refreshCalls = 0
    private(set) var addCalls: [(productId: String, by: Int)] = []
    private(set) var setQtyCalls: [(productId: String, qty: Int)] = []
    private(set) var removeCalls: [String] = []
    private(set) var clearCalls = 0

    func observeItems() -> AnyPublisher<[CartItem], Never> { itemsSubject.eraseToAnyPublisher() }
    func observeTotals() -> AnyPublisher<(count: Int, price: Double), Never> { totalsSubject.eraseToAnyPublisher() }

    func refresh(uid: String) async throws { refreshCalls += 1 }
    func add(productId: String, by delta: Int) async throws { addCalls.append((productId, delta)) }
    func setQuantity(productId: String, quantity: Int) async throws { setQtyCalls.append((productId, quantity)) }
    func remove(productId: String) async throws { removeCalls.append(productId) }
    func clear() async throws { clearCalls += 1 }
}
