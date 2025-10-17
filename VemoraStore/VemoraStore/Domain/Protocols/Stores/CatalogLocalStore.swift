//
//  CatalogLocalStore.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import Combine
import Foundation
import CoreData

/// Протокол `CatalogLocalStore`
///
/// Определяет интерфейс для **локального слоя хранения каталога товаров**, включающего продукты, категории и бренды.
///
/// Основные задачи:
/// - реактивное наблюдение за изменениями каталога (`observeProducts`, `observeCategories`, `observeBrands`);
/// - фильтрация и поиск товаров по категориям, брендам и диапазону цен;
/// - синхронизация локального состояния каталога с удалёнными данными (`upsertProducts`, `upsertCategories`, `upsertBrands`);
/// - предоставление метаинформации по товару (`meta(for:)`);
/// - интеграция с Core Data через `viewContext`.
///
/// Используется в:
/// - `CatalogRepository` для связывания локальных и удалённых источников данных;

protocol CatalogLocalStore: AnyObject {
    
    /// Контекст Core Data для фоновых и UI-операций.
    var viewContext: NSManagedObjectContext { get }
    
    // MARK: - Observe (reactive, Core Data -> Domain)
    
    /// Наблюдает за конкретным продуктом по идентификатору.
    /// - Parameter id: Идентификатор продукта.
    /// - Returns: Паблишер с моделью `Product?`.
    func observeProduct(id: String) -> AnyPublisher<Product?, Never>
    
    /// Наблюдает за товарами с возможностью фильтрации и поиска.
    /// - Parameters:
    ///   - query: Строка поиска.
    ///   - categoryIds: Идентификаторы категорий.
    ///   - brandIds: Идентификаторы брендов.
    ///   - minPrice: Минимальная цена.
    ///   - maxPrice: Максимальная цена.
    /// - Returns: Паблишер с массивом `Product`.
    func observeProducts(
        query: String?,
        categoryIds: Set<String>?,
        brandIds: Set<String>?,
        minPrice: Decimal?,
        maxPrice: Decimal?
    ) -> AnyPublisher<[Product], Never>
    
    /// Упрощённое наблюдение за товарами по поисковому запросу и категории.
    /// - Parameters:
    ///   - query: Текст поиска.
    ///   - categoryId: Идентификатор категории.
    /// - Returns: Паблишер с массивом `Product`.
    func observeProducts(query: String?, categoryId: String?) -> AnyPublisher<[Product], Never>
    
    /// Наблюдает за всеми категориями каталога.
    /// - Returns: Паблишер с массивом `Category`.
    func observeCategories() -> AnyPublisher<[Category], Never>
    
    /// Наблюдает за всеми брендами каталога.
    /// - Returns: Паблишер с массивом `Brand`.
    func observeBrands() -> AnyPublisher<[Brand], Never>
    
    // MARK: - Upsert (bulk, DTO -> Core Data)
    
    /// Обновляет или добавляет товары в локальное хранилище.
    /// - Parameter dtos: Массив DTO продуктов.
    func upsertProducts(_ dtos: [ProductDTO])
    
    /// Обновляет или добавляет категории.
    /// - Parameter dtos: Массив DTO категорий.
    func upsertCategories(_ dtos: [CategoryDTO])
    
    /// Обновляет или добавляет бренды.
    /// - Parameter dtos: Массив DTO брендов.
    func upsertBrands(_ dtos: [BrandDTO])
    
    /// Возвращает метаинформацию по товару.
    /// - Parameter productId: Идентификатор товара.
    /// - Returns: Модель `ProductMeta` с краткими данными.
    func meta(for productId: String) -> ProductMeta?
}

/// Краткая структура метаданных о товаре.
///
/// Содержит только ключевую информацию, необходимую для отображения
/// карточек, рекомендаций и предзагрузки данных.
public struct ProductMeta {
    /// Название бренда.
    public let brandName: String
    /// Название товара.
    public let title: String
    /// Цена товара.
    public let price: Double
    /// URL изображения товара.
    public let imageURL: URL?
    
    public init(
        brandName: String,
        title: String,
        price: Double,
        imageURL: URL?
    ) {
        self.brandName = brandName
        self.title = title
        self.price = price
        self.imageURL = imageURL
    }
}
