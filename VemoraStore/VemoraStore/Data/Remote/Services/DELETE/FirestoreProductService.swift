//
//  FirestoreProductService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

final class FirestoreProductService: ProductServiceProtocol {

    func products() -> AnyPublisher<[ProductTest], any Error> {
        let p = placeholderProducts()
        return Just(p)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func products(in categoryId: String) -> AnyPublisher<[ProductTest], any Error> {
        let p = placeholderProducts().filter { $0.categoryId == categoryId }
        return Just(p)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func categories() -> AnyPublisher<[CategoryTest], any Error> {
        let cats: [CategoryTest] = [
            CategoryTest(id: "chairs", name: "Стулья", icon: nil),
            CategoryTest(id: "tables", name: "Столы", icon: nil),
            CategoryTest(id: "sofas",  name: "Диваны", icon: nil)
        ]
        return Just(cats)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

// MARK: - Stubs
private extension FirestoreProductService {
    func placeholderProducts() -> [ProductTest] {
        let img1 = URL(string: "https://via.placeholder.com/600x600?text=Chair")!
        let img2 = URL(string: "https://via.placeholder.com/600x600?text=Table")!
        let img3 = URL(string: "https://via.placeholder.com/600x600?text=Sofa")!

        return [
            ProductTest(
                id: "1",
                name: "Стул «Comfort»",
                description: "Удобный стул для кухни и гостиной.",
                price: 1999,
                image: img1,
                categoryId: "chairs",
                brendId: "brand1"
            ),
            ProductTest(
                id: "2",
                name: "Стол обеденный «Classic»",
                description: "Прочный стол на 4–6 персон.",
                price: 8999,
                image: img2,
                categoryId: "tables",
                brendId: "brand2"
            ),
            ProductTest(
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
