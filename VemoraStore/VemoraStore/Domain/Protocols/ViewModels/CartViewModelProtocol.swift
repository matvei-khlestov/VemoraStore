//
//  CartViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 22.09.2025.
//

import Foundation
import Combine

/// Протокол `CartViewModelProtocol` определяет интерфейс ViewModel
/// для экрана корзины, предоставляя реактивные данные и методы
/// для управления товарами и их количеством.
///
/// Описывает публичные паблишеры, состояние и интенты,
/// используемые во `CartViewController`
/// для биндинга UI и реакции на действия пользователя.

protocol CartViewModelProtocol {
    
    // MARK: - Publishers
    
    /// Паблишер списка товаров в корзине.
    var cartItemsPublisher: AnyPublisher<[CartItem], Never> { get }
    
    // MARK: - State
    
    /// Текущий список товаров в корзине.
    var cartItems: [CartItem] { get }
    
    /// Количество уникальных позиций.
    var count: Int { get }
    
    /// Общее количество единиц товаров.
    var totalItems: Int { get }
    
    /// Общая сумма всех товаров.
    var totalPrice: Double { get }
    
    // MARK: - Access
    
    /// Возвращает элемент корзины по индексу.
    func item(at indexPath: IndexPath) -> CartItem
    
    // MARK: - Quantity Management
    
    /// Устанавливает количество для конкретного товара.
    func setQuantity(for productId: String, quantity: Int)
    
    /// Увеличивает количество указанного товара.
    func increaseQuantity(for productId: String)
    
    /// Уменьшает количество указанного товара.
    func decreaseQuantity(for productId: String)
    
    // MARK: - Modifications
    
    /// Удаляет товар по идентификатору.
    func removeItem(with productId: String)
    
    /// Полностью очищает корзину.
    func clearCart()
    
    // MARK: - Formatting
    
    /// Форматирует цену для отображения в UI.
    func formattedPrice(_ price: Double) -> String
    
    // MARK: - Notifications
    
    /// Планирует напоминание о незавершённой корзине при уходе с экрана.
    func scheduleCartReminderForLeavingScreen()
}
