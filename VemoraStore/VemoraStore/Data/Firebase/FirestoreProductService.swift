//
//  FirestoreProductService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

final class FirestoreProductService: ProductServiceProtocol {
    func products() -> AnyPublisher<[Product], any Error> {
        Just([
            Product(id: "1", name: "Стул", description: "Удобный стул", price: 1999,
                    images: [], categoryId: "chairs", inStock: true, rating: 4.5),
            Product(id: "2", name: "Стол", description: "Обеденный стол", price: 8999,
                    images: [], categoryId: "tables", inStock: true, rating: 4.8)
        ])
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
    
    func products(in categoryId: String) -> AnyPublisher<[Product], any Error> {
        Just([
            Product(id: "3", name: "Диван", description: "Комфортный диван", price: 14999,
                    images: [], categoryId: categoryId, inStock: true, rating: 4.7)
        ])
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
    
    func categories() -> AnyPublisher<[Category], any Error> {
        Just([
            Category(id: "chairs", name: "Стулья", icon: nil),
            Category(id: "tables", name: "Столы", icon: nil),
            Category(id: "sofas", name: "Диваны", icon: nil)
        ])
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
}
