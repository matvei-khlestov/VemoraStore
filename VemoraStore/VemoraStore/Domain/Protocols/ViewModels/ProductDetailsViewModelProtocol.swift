//
//  ProductDetailsViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 22.09.2025.
//

import Foundation
import Combine

/// Протокол `ProductDetailsViewModelProtocol` определяет интерфейс ViewModel
/// для экрана карточки товара, предоставляя реактивные данные и методы
/// для управления состоянием товара в корзине и избранном.
///
/// Описывает все выходные данные для UI (`Outputs`)
/// и доступные действия пользователя (`Actions`),
/// используемые во `ProductDetailsViewController`.

protocol ProductDetailsViewModelProtocol: AnyObject {
    
    // MARK: - Outputs (для UI)
    
    /// Название товара.
    var title: String { get }
    
    /// Описание товара.
    var description: String { get }
    
    /// Отформатированная цена товара.
    var priceText: String { get }
    
    /// URL изображения товара.
    var imageURL: String? { get }
    
    /// Флаг, находится ли товар в избранном.
    var isFavorite: Bool { get }
    
    /// Флаг, находится ли товар в корзине.
    var currentIsInCart: Bool { get }
    
    /// Паблишер, отправляющий обновления данных товара.
    var productPublisher: AnyPublisher<Product?, Never> { get }
    
    /// Паблишер, уведомляющий об изменении состояния корзины.
    var isInCartPublisher: AnyPublisher<Bool, Never> { get }
    
    /// Паблишер, уведомляющий об изменении состояния избранного.
    var isFavoritePublisher: AnyPublisher<Bool, Never> { get }
    
    // MARK: - Actions
    
    /// Переключает состояние избранного (добавить/удалить).
    func toggleFavorite()
    
    /// Добавляет товар в избранное.
    func addToFavorites()
    
    /// Удаляет товар из избранного.
    func removeFromFavorites()
    
    /// Добавляет товар в корзину (количество по умолчанию — 1).
    func addToCart()
    
    /// Добавляет товар в корзину в указанном количестве.
    func addToCart(quantity: Int)
    
    /// Обновляет количество товара в корзине.
    func updateQuantity(_ quantity: Int)
    
    /// Удаляет товар из корзины.
    func removeFromCart()
}
