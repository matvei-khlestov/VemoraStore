//
//  CatalogViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine
import FactoryKit

final class CatalogViewModel {

    // Input
    @Published var query: String = ""

    // Output
    @Published private(set) var categories: [(title: String, count: Int, imageURL: URL?)] = []
    @Published private(set) var products: [Product] = []

    private let productService: ProductServiceProtocol
    private var bag = Set<AnyCancellable>()

    init(productService: ProductServiceProtocol = Container.shared.productService()) {
        self.productService = productService
        bind()
    }

    private func bind() {
        // пример фильтрации по запросу (заглушка — фильтруем локально)
        $query
            .removeDuplicates()
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .sink { [weak self] q in
                guard let self else { return }
                if q.isEmpty {
                    // показать полный список (если нужно — снова дернуть сервис)
                } else {
                    self.products = self.products.filter { $0.name.localizedCaseInsensitiveContains(q) }
                }
            }
            .store(in: &bag)
    }

    func reload() {
        categories = [
            ("Bathing", 52, nil),
            ("Bed & Frame", 59, nil),
            ("Bedding", 72, nil),
            ("Coffee table", 20, nil),
        ]
        
        products = [
            Product(
                id: "1",
                name: "Modern Nesting Wood Coffee Table with Gold...",
                description: "Elegant nesting coffee table with gold accents.",
                price: 57.60,
                image: URL(string: "https://via.placeholder.com/300")!,
                categoryId: "coffee",
                brendId: "brand1"
            ),
            Product(
                id: "2",
                name: "Tribesigns Modern Home Decor Round Side Table",
                description: "Round side table for living room.",
                price: 7.48,
                image: URL(string: "https://via.placeholder.com/300")!,
                categoryId: "coffee",
                brendId: "brand2"
            ),
            Product(
                id: "2",
                name: "Tribesigns Modern Home Decor Round Side Table",
                description: "Round side table for living room.",
                price: 7.48,
                image: URL(string: "https://via.placeholder.com/300")!,
                categoryId: "coffee",
                brendId: "brand2"
            ),
            Product(
                id: "2",
                name: "Tribesigns Modern Home Decor Round Side Table",
                description: "Round side table for living room.",
                price: 7.48,
                image: URL(string: "https://via.placeholder.com/300")!,
                categoryId: "coffee",
                brendId: "brand2"
            ),
            Product(
                id: "2",
                name: "Tribesigns Modern Home Decor Round Side Table",
                description: "Round side table for living room.",
                price: 7.48,
                image: URL(string: "https://via.placeholder.com/300")!,
                categoryId: "coffee",
                brendId: "brand2"
            ),
            Product(
                id: "2",
                name: "Tribesigns Modern Home Decor Round Side Table",
                description: "Round side table for living room.",
                price: 7.48,
                image: URL(string: "https://via.placeholder.com/300")!,
                categoryId: "coffee",
                brendId: "brand2"
            )
        ]
    }

}

