//
//  CartRepository.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 11.10.2025.
//

import Combine

/// Протокол `CartRepository`
///
/// Определяет единый интерфейс для управления корзиной пользователя,
/// объединяя локальное (`CartLocalStore`) и удалённое (`CartCollectingProtocol`)
/// хранилища данных.
///
/// Основные задачи:
/// - предоставление реактивного состояния корзины (`observeItems`, `observeTotals`);
/// - синхронизация локальных данных с сервером (`refresh`);
/// - управление количеством товаров (`add`, `setQuantity`, `remove`);
/// - очистка корзины (`clear`).
///
/// Используется в:
/// - `CartViewModel` для отображения текущего состояния корзины;
/// - `CheckoutViewModel` для получения снапшота товаров при оформлении заказа;
/// - `ProductDetailsViewModel` для добавления товаров в корзину.
///
/// Репозиторий скрывает детали синхронизации между локальной и удалённой логикой
/// и обеспечивает согласованность данных с помощью Combine и async/await.

protocol CartRepository: AnyObject {
    
    // MARK: - Streams
    
    /// Наблюдает за текущим содержимым корзины.
    /// - Returns: Паблишер, эмитирующий массив `CartItem` при изменениях.
    func observeItems() -> AnyPublisher<[CartItem], Never>
    
    /// Наблюдает за общими итогами корзины (количество и сумма).
    /// - Returns: Паблишер с кортежем `(count, price)`.
    func observeTotals() -> AnyPublisher<(count: Int, price: Double), Never>
    
    // MARK: - Commands
    
    /// Обновляет локальные данные корзины, синхронизируя их с сервером.
    /// - Parameter uid: Идентификатор пользователя.
    func refresh(uid: String) async throws
    
    /// Добавляет товар в корзину или изменяет его количество.
    /// - Parameters:
    ///   - productId: Идентификатор товара.
    ///   - delta: Изменение количества (например, `+1` или `-1`).
    func add(productId: String, by delta: Int) async throws
    
    /// Устанавливает новое количество товара.
    /// - Parameters:
    ///   - productId: Идентификатор товара.
    ///   - quantity: Новое количество.
    func setQuantity(productId: String, quantity: Int) async throws
    
    /// Удаляет товар из корзины.
    /// - Parameter productId: Идентификатор товара.
    func remove(productId: String) async throws
    
    /// Полностью очищает корзину (например, после оформления заказа).
    func clear() async throws
}
