//
//  CatalogViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

final class CatalogViewModel: CatalogViewModelProtocol {
    
    @Published var query: String = ""
    
    @Published private(set) var categories: [(title: String, count: Int, imageURL: URL?)] = []
    @Published private(set) var products: [ProductTest] = []
    
    var categoriesPublisher: AnyPublisher<[(title: String, count: Int, imageURL: URL?)], Never> {
        $categories.eraseToAnyPublisher()
    }
    var productsPublisher: AnyPublisher<[ProductTest], Never> {
        $products.eraseToAnyPublisher()
    }
    
    private let productService: ProductServiceProtocol
    private var bag = Set<AnyCancellable>()
    
    init(productService: ProductServiceProtocol) {
        self.productService = productService
        bind()
    }
    
    private func bind() {
        $query
            .removeDuplicates()
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .sink { [weak self] q in
                guard let self else { return }
                if q.isEmpty {
                    // можно перезагрузить из сервиса
                } else {
                    self.products = self.products.filter {
                        $0.name.localizedCaseInsensitiveContains(q)
                    }
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
            ProductTest(
                id: "1",
                name: "Modern Nesting Wood Coffee Table with Gold...",
                description: "Elegant nesting coffee table with gold accents.",
                price: 57.60,
                image: URL(string: "https://via.placeholder.com/300")!,
                categoryId: "coffee",
                brendId: "brand1"
            ),
            ProductTest(
                id: "2",
                name: "Tribesigns Modern Home Decor Round Side Table",
                description: "Компактное кресло с мягкой бежевой обивкой и ножками из натурального дуба. Подойдёт для небольших гостиных или спален, создавая уютное место для отдыха.",
                price: 7.48,
                image: URL(string: "https://via.placeholder.com/300")!,
                categoryId: "coffee",
                brendId: "brand2"
            ),
            ProductTest(
                id: "2",
                name: "Tribesigns Modern Home Decor Round Side Table",
                description: "Round side table for living room.",
                price: 7.48,
                image: URL(string: "https://via.placeholder.com/300")!,
                categoryId: "coffee",
                brendId: "brand2"
            ),
            ProductTest(
                id: "2",
                name: "Tribesigns Modern Home Decor Round Side Table",
                description: "Round side table for living room.",
                price: 7.48,
                image: URL(string: "https://via.placeholder.com/300")!,
                categoryId: "coffee",
                brendId: "brand2"
            ),
            ProductTest(
                id: "2",
                name: "Tribesigns Modern Home Decor Round Side Table",
                description: "Round side table for living room.",
                price: 7.48,
                image: URL(string: "https://via.placeholder.com/300")!,
                categoryId: "coffee",
                brendId: "brand2"
            ),
            ProductTest(
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

