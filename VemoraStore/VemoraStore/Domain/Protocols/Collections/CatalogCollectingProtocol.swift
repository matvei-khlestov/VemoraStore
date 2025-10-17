//
//  CatalogCollectingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import Combine

/// Протокол `CatalogCollectingProtocol`
///
/// Определяет интерфейс для работы с удалёнными данными **каталога товаров**.
///
/// Основные задачи:
/// - загрузка справочной информации каталога (`fetchProducts`, `fetchCategories`, `fetchBrands`);
/// - реактивное получение изменений (`listenProducts`, `listenCategories`, `listenBrands`);
/// - предоставление данных для фильтров, карточек и детальных экранов.
///
/// Используется в:
/// - `CatalogRepository` для агрегации данных каталога;
/// - `CatalogViewModel`, `CatalogFilterViewModel`, `ProductDetailsViewModel`
///   для отображения товаров, категорий и брендов.

protocol CatalogCollectingProtocol: AnyObject {
    
    /// Загружает список всех товаров.
    /// - Returns: Массив `ProductDTO` с основной информацией о товарах.
    func fetchProducts() async throws -> [ProductDTO]
    
    /// Загружает список категорий каталога.
    /// - Returns: Массив `CategoryDTO` с категориями.
    func fetchCategories() async throws -> [CategoryDTO]
    
    /// Загружает список брендов.
    /// - Returns: Массив `BrandDTO` с доступными брендами.
    func fetchBrands() async throws -> [BrandDTO]
    
    /// Реактивно слушает изменения в списке товаров.
    /// - Returns: Паблишер с актуальными `ProductDTO`.
    func listenProducts() -> AnyPublisher<[ProductDTO], Never>
    
    /// Реактивно слушает изменения в списке категорий.
    /// - Returns: Паблишер с актуальными `CategoryDTO`.
    func listenCategories() -> AnyPublisher<[CategoryDTO], Never>
    
    /// Реактивно слушает изменения в списке брендов.
    /// - Returns: Паблишер с актуальными `BrandDTO`.
    func listenBrands() -> AnyPublisher<[BrandDTO], Never>
}
