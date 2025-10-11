//
//  CatalogRepository.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import Combine
import Foundation

// MARK: - CatalogRepository

protocol CatalogRepository: AnyObject {
    
    // MARK: - Observe (локальные, реактивные)
    
    func observeProducts(query: String?, categoryId: String?) -> AnyPublisher<[Product], Never>
    func observeCategories() -> AnyPublisher<[Category], Never>
    func observeBrands() -> AnyPublisher<[Brand], Never>

    func observeProducts(
        query: String?,
        categoryIds: Set<String>?,
        brandIds: Set<String>?,
        minPrice: Decimal?,
        maxPrice: Decimal?
    ) -> AnyPublisher<[Product], Never>

    // MARK: - Refresh (одноразовая подтяжка снапшота с сервера → локально)
    
    func refreshAll() async throws

    // MARK: - Realtime (жизненный цикл слушателей управляет сам репозиторий)
    func startRealtimeSync()
    func stopRealtimeSync()
}

// MARK: - Backward Compatibility

extension CatalogRepository {
    func observeProducts(query: String?, categoryId: String?) -> AnyPublisher<[Product], Never> {
        observeProducts(
            query: query,
            categoryIds: categoryId.flatMap { [$0] }.map(Set.init),
            brandIds: nil,
            minPrice: nil,
            maxPrice: nil
        )
    }
}
