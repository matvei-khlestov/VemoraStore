//
//  CatalogViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 22.09.2025.
//

import Combine

/// Протокол `CatalogViewModelProtocol` определяет интерфейс ViewModel
/// для экрана каталога, предоставляя реактивные данные и действия
/// для управления категориями, товарами и фильтрацией.
///
/// Описывает все выходные данные (`Outputs`) и интенты (`Actions`),
/// используемые во `CatalogViewController`.
///
/// Основные задачи:
/// - загрузка и наблюдение за категориями и товарами (`CatalogRepository`);
/// - применение и обновление фильтров (`FilterState`);
/// - управление состоянием корзины и избранного;
/// - форматирование цен через `PriceFormattingProtocol`.
///
/// Реактивность:
/// - обновления передаются через Combine-паблишеры;
/// - все изменения доставляются на главный поток.

protocol CatalogViewModelProtocol: AnyObject {
    
    // MARK: - Search
    
    /// Текущий поисковый запрос.
    var query: String { get set }
    
    /// Перезагружает данные каталога.
    func reload()
    
    // MARK: - Categories & Products
    
    /// Массив категорий.
    var categories: [Category] { get }
    
    /// Массив товаров.
    var products: [Product] { get }
    
    /// Паблишер категорий.
    var categoriesPublisher: AnyPublisher<[Category], Never> { get }
    
    /// Паблишер товаров.
    var productsPublisher: AnyPublisher<[Product], Never> { get }
    
    // MARK: - Filters
    
    /// Текущее состояние фильтров.
    var currentState: FilterState { get }
    
    /// Применяет новое состояние фильтров.
    func applyFilters(_ state: FilterState)
    
    /// Количество активных фильтров.
    var activeFiltersCount: Int { get }
    
    /// Паблишер количества активных фильтров.
    var activeFiltersCountPublisher: AnyPublisher<Int, Never> { get }
    
    // MARK: - Cart
    
    /// Паблишер ID товаров, находящихся в корзине.
    var inCartIdsPublisher: AnyPublisher<Set<String>, Never> { get }
    
    /// Добавляет товар в корзину.
    func addToCart(productId: String)
    
    /// Удаляет товар из корзины.
    func removeFromCart(productId: String)
    
    // MARK: - Favorites
    
    /// Паблишер ID товаров, находящихся в избранном.
    var favoriteIdsPublisher: AnyPublisher<Set<String>, Never> { get }
    
    /// Добавляет товар в избранное.
    func addToFavorites(productId: String)
    
    /// Удаляет товар из избранного.
    func removeFromFavorites(productId: String)
    
    /// Переключает состояние избранного.
    func toggleFavorite(productId: String)
    
    // MARK: - Helpers
    
    /// Возвращает количество товаров в категории.
    func productCount(in categoryId: String) -> Int
    
    /// Форматирует цену в строку.
    func formattedPrice(_ price: Double) -> String
}
