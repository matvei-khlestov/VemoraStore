//
//  CartService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

final class CartService: CartServiceProtocol {
    static let shared = CartService()
    private init() {}

    private let subject = CurrentValueSubject<[CartItemEntity], Never>([])
    
    var itemsPublisher: AnyPublisher<[CartItemEntity], Never> {
        subject.eraseToAnyPublisher()
    }
    
    func add(product: Product) {
        var items = subject.value
        if let index = items.firstIndex(where: { $0.id == product.id }) {
            // увеличиваем количество, если товар уже есть
            items[index].quantity += 1
        } else {
            // добавляем новый элемент
            let item = CartItemEntity(id: product.id, product: product, quantity: 1)
            items.append(item)
        }
        subject.send(items)
    }
    
    func remove(id: String) {
        var items = subject.value
        items.removeAll { $0.id == id }
        subject.send(items)
    }
    
    func changeQuantity(id: String, qty: Int) {
        guard qty > 0 else {
            remove(id: id)
            return
        }
        var items = subject.value
        if let index = items.firstIndex(where: { $0.id == id }) {
            items[index].quantity = qty
            subject.send(items)
        }
    }
    
    func clear() {
        subject.send([])
    }
    
    func total() -> Double {
        subject.value.reduce(0) { $0 + $1.totalPrice }
    }
}

