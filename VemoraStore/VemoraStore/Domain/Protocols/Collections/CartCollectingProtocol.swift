//
//  CartCollectingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 11.10.2025.
//

import Foundation
import Combine

protocol CartCollectingProtocol: AnyObject {
    func fetchCart(uid: String) async throws -> [CartDTO]
    func setQuantity(uid: String, dto: CartDTO, quantity: Int) async throws
    func addOrAccumulate(uid: String, dto: CartDTO, by delta: Int) async throws
    func remove(uid: String, productId: String) async throws
    func clear(uid: String) async throws
    
    func listenCart(uid: String) -> AnyPublisher<[CartDTO], Never>
}
