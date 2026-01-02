//
//  DefaultCatalogRepository.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import Foundation
import Combine
import CoreData

/// Класс `DefaultCatalogRepository` — реализация репозитория каталога
///
/// Назначение:
/// - объединяет удалённый источник (`CatalogCollectingProtocol`) и локальное хранилище (`CatalogLocalStore`);
/// - обеспечивает реактивное наблюдение за товарами, категориями и брендами из Core Data (через FRC-паблишеры);
/// - синхронизирует локальные данные с Firestore: «снимком» (`refreshAll()`) и в реальном времени (`startRealtimeSync()`).
///
/// Состав:
/// - `remote` — Firestore-коллекции (products/categories/brands);
/// - `local` — Core Data store (upsert + FRC-потоки);
/// - `bag` — контейнер подписок Combine;
/// - `isRealtimeStarted` — флаг активной realtime-синхронизации;
/// - `liveProductStreams` — удержание живых FRC-паблишеров по UUID (для множественных фильтров).
///
/// Основные функции:
/// - Observe (локально):
///   - `observeProducts(query:categoryId:)` — поток товаров по простому фильтру;
///   - `observeProducts(query:categoryIds:brandIds:minPrice:maxPrice:)` — универсальный наблюдатель с множественными фильтрами (держит FRC в памяти, авто-освобождение по cancel);
///   - `observeProduct(id:)` — поток одного товара;
///   - `observeCategories()` / `observeBrands()` — потоки категорий/брендов.
/// - Refresh (one-shot):
///   - `refreshAll()` — параллельно тянет продукты/категории/бренды из Firestore и делает upsert в Core Data.
/// - Realtime:
///   - `startRealtimeSync()` — один раз запускает начальный `refreshAll()` и подписки на `listen*` у `remote`, перенаправляя апдейты в локальный upsert;
///   - `stopRealtimeSync()` — останавливает realtime-подписки (очищает `bag`).
///
/// Особенности:
/// - чтение — всегда из локального стора (UI-реактивность через FRC);
/// - запись — через upsert в локаль при приходе данных из Firestore;
/// - защита от двойного старта realtime через `isRealtimeStarted`.

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
