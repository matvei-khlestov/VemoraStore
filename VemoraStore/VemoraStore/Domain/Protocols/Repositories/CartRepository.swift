//
//  CartRepository.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 11.10.2025.
//

import Combine

protocol CartRepository: AnyObject {
    func observeItems() -> AnyPublisher<[CartItem], Never>
    func observeTotals() -> AnyPublisher<(count: Int, price: Double), Never>
    
    func refresh(uid: String) async throws
    
    func add(productId: String, by delta: Int) async throws
    func setQuantity(productId: String, quantity: Int) async throws
    func remove(productId: String) async throws
    func clear() async throws
}
