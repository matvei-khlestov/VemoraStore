//
//  CatalogRepository.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import Combine
import Foundation

/// Протокол `CatalogRepository`
///
/// Определяет единый интерфейс для доступа к данным каталога товаров —
/// категории, бренды и продукты. Репозиторий объединяет локальный слой
/// (`CatalogLocalStore`) и удалённый (`CatalogCollectingProtocol`),
/// обеспечивая синхронизацию и реактивное обновление состояния.
///
/// Основные задачи:
/// - предоставление реактивных потоков (`observeProducts`, `observeCategories`, `observeBrands`);
/// - синхронизация данных каталога с сервером (`refreshAll`);
/// - поддержка фоновой синхронизации в реальном времени (`startRealtimeSync`, `stopRealtimeSync`);
/// - унифицированное наблюдение за товарами с фильтрацией по категории, бренду и цене.
///
/// Используется в:
/// - `CatalogViewModel` для отображения общего каталога;
/// - `CategoryProductsViewModel` для фильтрации по категориям;
/// - `CatalogFilterViewModel` для фильтрации по брендам и диапазону цен;
/// - `ProductDetailsViewModel` для получения данных о конкретном товаре.
///
/// Репозиторий обеспечивает целостность данных каталога и синхронизирует
/// локальное хранилище с удалённым источником через Combine и async/await.

protocol CatalogRepository: AnyObject {
    
    // MARK: - Observe (локальные, реактивные)
    
    /// Наблюдает за списком товаров по заданным фильтрам.
    /// - Parameters:
    ///   - query: Текстовый запрос (поиск по названию).
    ///   - categoryIds: Набор идентификаторов категорий.
    ///   - brandIds: Набор идентификаторов брендов.
    ///   - minPrice: Минимальная цена.
    ///   - maxPrice: Максимальная цена.
    /// - Returns: Паблишер массива `Product`, обновляющийся при изменении данных.
    func observeProducts(
        query: String?,
        categoryIds: Set<String>?,
        brandIds: Set<String>?,
        minPrice: Decimal?,
        maxPrice: Decimal?
    ) -> AnyPublisher<[Product], Never>
    
    /// Наблюдает за товарами в рамках конкретной категории.
    /// - Parameters:
    ///   - query: Текстовый запрос (опционально).
    ///   - categoryId: Идентификатор категории.
    /// - Returns: Паблишер массива `Product`.
    func observeProducts(query: String?, categoryId: String?) -> AnyPublisher<[Product], Never>
    
    /// Наблюдает за всеми категориями каталога.
    /// - Returns: Паблишер массива `Category`.
    func observeCategories() -> AnyPublisher<[Category], Never>
    
    /// Наблюдает за всеми брендами.
    /// - Returns: Паблишер массива `Brand`.
    func observeBrands() -> AnyPublisher<[Brand], Never>
    
    /// Наблюдает за конкретным товаром по идентификатору.
    /// - Parameter id: Идентификатор товара.
    /// - Returns: Паблишер `Product?`, эмитирующий изменения конкретного товара.
    func observeProduct(id: String) -> AnyPublisher<Product?, Never>

    // MARK: - Refresh
    
    /// Выполняет обновление локального хранилища каталога,
    /// подтягивая актуальные данные с сервера.
    func refreshAll() async throws

    // MARK: - Realtime
    
    /// Запускает фоновую синхронизацию каталога в реальном времени.
    func startRealtimeSync()
    
    /// Останавливает фоновую синхронизацию каталога.
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
