//
//  DefaultCatalogRepository.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import Foundation
import Combine
import CoreData

// MARK: - DefaultCatalogRepository

final class DefaultCatalogRepository: CatalogRepository {
    
    // MARK: - Deps
    
    private let remote: CatalogCollectingProtocol
    private let local: CatalogLocalStore
    
    // MARK: - State
    
    private var bag = Set<AnyCancellable>()
    private var isRealtimeStarted = false
    
    private var liveProductStreams: [UUID: AnyObject] = [:]
    
    // MARK: - Init
    
    init(remote: CatalogCollectingProtocol, local: CatalogLocalStore) {
        self.remote = remote
        self.local = local
    }
    
    // MARK: - Observe (локально)
    
    func observeProducts(query: String?, categoryId: String?) -> AnyPublisher<[Product], Never> {
        local.observeProducts(query: query, categoryId: categoryId)
    }
    
    func observeCategories() -> AnyPublisher<[Category], Never> {
        local.observeCategories()
    }
    
    func observeBrands() -> AnyPublisher<[Brand], Never> {
        local.observeBrands()
    }

    // Observe single product by id
    func observeProduct(id: String) -> AnyPublisher<Product?, Never> {
        local.observeProduct(id: id)
    }
    
    /// Универсальный наблюдатель с множественными фильтрами + удержание FRC
    func observeProducts(
        query: String?,
        categoryIds: Set<String>?,
        brandIds: Set<String>?,
        minPrice: Decimal?,
        maxPrice: Decimal?
    ) -> AnyPublisher<[Product], Never> {
        
        let key = UUID()
        
        let options = ProductsFRCPublisher.Options(
            query: query,
            categoryIds: categoryIds,
            brandIds: brandIds,
            minPrice: minPrice,
            maxPrice: maxPrice
        )
        let frcPub = ProductsFRCPublisher(
            context: local.viewContext,
            options: options
        )
        
        liveProductStreams[key] = frcPub
        
        return frcPub.publisher()
            .handleEvents(
                receiveCompletion: { [weak self] (_: Subscribers.Completion<Never>) in
                    self?.liveProductStreams[key] = nil
                }, receiveCancel: { [weak self] in
                    self?.liveProductStreams[key] = nil
                }
            )
            .eraseToAnyPublisher()
    }
    
    // MARK: - Refresh (одноразовая подтяжка)
    
    func refreshAll() async throws {
        async let p = remote.fetchProducts()
        async let c = remote.fetchCategories()
        async let b = remote.fetchBrands()
        
        let (products, categories, brands) = try await (p, c, b)
        local.upsertProducts(products)
        local.upsertCategories(categories)
        local.upsertBrands(brands)
    }
    
    // MARK: - Realtime
    
    func startRealtimeSync() {
        guard !isRealtimeStarted else { return }
        isRealtimeStarted = true
        
        Task {
            do { try await refreshAll() }
            catch { print("❌ startRealtimeSync.refreshAll error:", error) }
        }
        
        remote.listenProducts()
            .sink { [weak self] dtos in
                self?.local.upsertProducts(dtos)
            }
            .store(in: &bag)
        
        remote.listenCategories()
            .sink { [weak self] dtos in
                self?.local.upsertCategories(dtos)
            }
            .store(in: &bag)
        
        remote.listenBrands()
            .sink { [weak self] dtos in
                self?.local.upsertBrands(dtos)
            }
            .store(in: &bag)
    }
    
    func stopRealtimeSync() {
        isRealtimeStarted = false
        bag.removeAll()
    }
}
