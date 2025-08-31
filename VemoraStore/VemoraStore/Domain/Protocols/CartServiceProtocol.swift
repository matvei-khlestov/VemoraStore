//
//  CartServiceProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

protocol CartServiceProtocol {
    var itemsPublisher: AnyPublisher<[CartItemEntity], Never> { get }
    func add(product: Product)
    func remove(id: String)
    func changeQuantity(id: String, qty: Int)
    func clear()
    func total() -> Double
}
