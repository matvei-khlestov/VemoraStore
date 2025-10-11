//
//  CatalogViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 22.09.2025.
//

import Combine

protocol CatalogViewModelProtocol: AnyObject {
    // Inputs
    var query: String { get set }
    func reload()

    // Outputs
    var categories: [Category] { get }
    var products: [Product] { get }
    var categoriesPublisher: AnyPublisher<[Category], Never> { get }
    var productsPublisher: AnyPublisher<[Product], Never> { get }

    // Filter state
    var currentState: FilterState { get }
    func applyFilters(_ state: FilterState)

    // Счётчик активных фильтров
    var activeFiltersCount: Int { get }
    var activeFiltersCountPublisher: AnyPublisher<Int, Never> { get }

    // Helpers
    func productCount(in categoryId: String) -> Int
}
