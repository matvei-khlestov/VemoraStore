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
        let p = placeholderProducts()
        return Just(p)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func products(in categoryId: String) -> AnyPublisher<[Product], any Error> {
        let p = placeholderProducts().filter { $0.categoryId == categoryId }
        return Just(p)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func categories() -> AnyPublisher<[Category], any Error> {
        let cats: [Category] = [
            Category(id: "chairs", name: "Стулья", icon: nil),
            Category(id: "tables", name: "Столы", icon: nil),
            Category(id: "sofas",  name: "Диваны", icon: nil)
        ]
        return Just(cats)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

// MARK: - Stubs
private extension FirestoreProductService {
    func placeholderProducts() -> [Product] {
        let img1 = URL(string: "https://via.placeholder.com/600x600?text=Chair")!
        let img2 = URL(string: "https://via.placeholder.com/600x600?text=Table")!
        let img3 = URL(string: "https://via.placeholder.com/600x600?text=Sofa")!

        return [
            Product(
                id: "1",
                name: "Стул «Comfort»",
                description: "Удобный стул для кухни и гостиной.",
                price: 1999,
                image: img1,
                categoryId: "chairs",
                brendId: "brand1"
            ),
            Product(
                id: "2",
                name: "Стол обеденный «Classic»",
                description: "Прочный стол на 4–6 персон.",
                price: 8999,
                image: img2,
                categoryId: "tables",
                brendId: "brand2"
            ),
            Product(
                id: "3",
                name: "Диван «Relax»",
                description: "Комфортный диван для уютных вечеров.",
                price: 14999,
                image: img3,
                categoryId: "sofas",
                brendId: "brand1"
            )
        ]
    }
}
