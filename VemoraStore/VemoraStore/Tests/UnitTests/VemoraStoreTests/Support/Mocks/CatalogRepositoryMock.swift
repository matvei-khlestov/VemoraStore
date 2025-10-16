//
//  CatalogRepositoryMock.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import Foundation
import Combine
@testable import VemoraStore

final class CatalogRepositoryMock: CatalogRepository {

    // Streams
    let productsSubject   = CurrentValueSubject<[VemoraStore.Product], Never>([])
    let categoriesSubject = CurrentValueSubject<[VemoraStore.Category], Never>([])
    let brandsSubject     = CurrentValueSubject<[VemoraStore.Brand], Never>([])

    // Tracking
    private(set) var refreshAllCalls = 0
    private(set) var startRealtimeCalls = 0
    private(set) var stopRealtimeCalls = 0

    // Last subscribed params
    private(set) var lastQuery: String?
    private(set) var lastCategoryIds: Set<String>?
    private(set) var lastBrandIds: Set<String>?
    private(set) var lastMinPrice: Decimal?
    private(set) var lastMaxPrice: Decimal?

    // Legacy
    func observeProducts(query: String?, categoryId: String?) -> AnyPublisher<[VemoraStore.Product], Never> {
        _ = observeProducts(
            query: query,
            categoryIds: categoryId.map { Set([$0]) },
            brandIds: nil,
            minPrice: nil,
            maxPrice: nil
        )
        return productsSubject.eraseToAnyPublisher()
    }

    func observeCategories() -> AnyPublisher<[VemoraStore.Category], Never> {
        categoriesSubject.eraseToAnyPublisher()
    }

    func observeBrands() -> AnyPublisher<[VemoraStore.Brand], Never> {
        brandsSubject.eraseToAnyPublisher()
    }

    // Rich
    func observeProducts(
        query: String?,
        categoryIds: Set<String>?,
        brandIds: Set<String>?,
        minPrice: Decimal?,
        maxPrice: Decimal?
    ) -> AnyPublisher<[VemoraStore.Product], Never> {
        lastQuery = query
        lastCategoryIds = categoryIds
        lastBrandIds = brandIds
        lastMinPrice = minPrice
        lastMaxPrice = maxPrice
        return productsSubject.eraseToAnyPublisher()
    }

    func observeProduct(id: String) -> AnyPublisher<VemoraStore.Product?, Never> {
        productsSubject
            .map { items in items.first(where: { $0.id == id }) }
            .eraseToAnyPublisher()
    }

    func refreshAll() async throws { refreshAllCalls += 1 }
    func startRealtimeSync() { startRealtimeCalls += 1 }
    func stopRealtimeSync() { stopRealtimeCalls += 1 }
}
