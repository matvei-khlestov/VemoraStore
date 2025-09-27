//
//  CartServiceProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

protocol CartServiceProtocol {
    var itemsPublisher: AnyPublisher<[CartItem], Never> { get }

    func add(product: ProductTest, quantity: Int)
    func setQuantity(productId: String, quantity: Int)
    func increase(productId: String)
    func decrease(productId: String)
    func remove(productId: String)

    func loadMocks()
}
