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
    func placeholderProducts() -> [Product] {
        let img1 = URL(string: "https://via.placeholder.com/600x600?text=Chair")!
        let img2 = URL(string: "https://via.placeholder.com/600x600?text=Table")!
        let img3 = URL(string: "https://via.placeholder.com/600x600?text=Sofa")!

        return [
            Product(
                id: "1",
                name: "Стул «Comfort»",
                description: "Удобный стул для кухни и гостиной.",
                nameLower: "стул «comfort»",
                categoryId: "chairs",
                brandId: "brand1",
                price: 1999,
                imageURL: "img1",
                isActive: true,
                createdAt: ISO8601DateFormatter().string(from: Date()),
                updatedAt: ISO8601DateFormatter().string(from: Date()),
                keywords: ["стул", "кухонный", "комфорт", "мебель"]
            ),
            Product(
                id: "2",
                name: "Стол обеденный «Classic»",
                description: "Прочный стол на 4–6 персон.",
                nameLower: "стол обеденный «classic»",
                categoryId: "tables",
                brandId: "brand2",
                price: 8999,
                imageURL: "",
                isActive: true,
                createdAt: ISO8601DateFormatter().string(from: Date()),
                updatedAt: ISO8601DateFormatter().string(from: Date()),
                keywords: ["стол", "обеденный", "классика", "мебель"]
            ),
            Product(
                id: "3",
                name: "Диван «Relax»",
                description: "Комфортный диван для уютных вечеров.",
                nameLower: "диван «relax»",
                categoryId: "sofas",
                brandId: "brand1",
                price: 14999,
                imageURL: "",
                isActive: true,
                createdAt: ISO8601DateFormatter().string(from: Date()),
                updatedAt: ISO8601DateFormatter().string(from: Date()),
                keywords: ["диван", "релакс", "гостиная", "мебель"]
            )
        ]
    }
}
