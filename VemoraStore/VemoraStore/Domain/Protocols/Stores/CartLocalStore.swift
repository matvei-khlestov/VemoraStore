//
//  CartLocalStore.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 11.10.2025.
//

import Combine
import CoreData

protocol CartLocalStore: AnyObject {
    func observeItems(userId: String) -> AnyPublisher<[CartItem], Never>
    func replaceAll(userId: String, with dtos: [CartDTO])
    func upsert(userId: String, dto: CartDTO, accumulate: Bool)
    func setQuantity(userId: String, productId: String, quantity: Int)
    func remove(userId: String, productId: String)
    func clear(userId: String)
}

