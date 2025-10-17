//
//  FavoritesViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 22.09.2025.
//

import Combine
import Foundation

/// Протокол `FavoritesViewModelProtocol` определяет интерфейс ViewModel
/// для экрана избранного, предоставляя реактивные данные и методы
/// для управления списком избранных товаров и их состоянием в корзине.
///
/// Описывает публичные паблишеры, состояние и интенты,
/// используемые во `FavoritesViewController`
/// для биндинга UI и реакции на действия пользователя.

protocol FavoritesViewModelProtocol {
    
    /// Публикует список избранных товаров.
    var favoriteItemsPublisher: AnyPublisher<[FavoriteItem], Never> { get }
    
    /// Публикует множество идентификаторов товаров, находящихся в корзине.
    var inCartIdsPublisher: AnyPublisher<Set<String>, Never> { get }
    
    /// Количество товаров в избранном.
    var count: Int { get }
    
    /// Возвращает товар по указанному индексу.
    func item(at indexPath: IndexPath) -> FavoriteItem
    
    /// Проверяет, находится ли товар в корзине.
    func isInCart(_ productId: String) -> Bool
    
    /// Добавляет или удаляет товар из корзины.
    func toggleCart(for productId: String)
    
    /// Удаляет товар из списка избранных.
    func removeItem(with productId: String)
    
    /// Полностью очищает список избранных.
    func clearFavorites()
    
    /// Форматирует цену для отображения.
    func formattedPrice(_ price: Double) -> String
}
