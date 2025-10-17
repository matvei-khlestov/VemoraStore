//
//  CartLocalStore.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 11.10.2025.
//

import Combine
import CoreData

/// Протокол `CartLocalStore`
///
/// Определяет интерфейс для **локального хранения корзины пользователя**
/// с поддержкой реактивных обновлений и синхронизации данных.
///
/// Основные задачи:
/// - наблюдение за локальными изменениями товаров в корзине (`observeItems`);
/// - обновление и замещение содержимого корзины (`upsert`, `replaceAll`);
/// - управление количеством товаров (`setQuantity`);
/// - удаление и очистка корзины (`remove`, `clear`);
/// - предоставление локального снимка корзины (`snapshot`).
///
/// Используется в:
/// - `CartRepository` для объединения локальных и удалённых источников данных;
///
/// Реализуется через `CoreData` или аналогичное хранилище.

protocol CartLocalStore: AnyObject {
    
    /// Наблюдает за изменениями товаров в корзине.
    /// - Parameter userId: Идентификатор пользователя.
    /// - Returns: Паблишер с массивом `CartItem`, обновляющимся при изменениях.
    func observeItems(userId: String) -> AnyPublisher<[CartItem], Never>
    
    /// Полностью заменяет локальные данные корзины новыми DTO.
    /// - Parameters:
    ///   - userId: Идентификатор пользователя.
    ///   - dtos: Новый список позиций корзины.
    func replaceAll(userId: String, with dtos: [CartDTO])
    
    /// Добавляет или обновляет товар в корзине, с возможностью накапливания количества.
    /// - Parameters:
    ///   - userId: Идентификатор пользователя.
    ///   - dto: DTO позиции корзины.
    ///   - accumulate: Флаг — если `true`, количество добавляется к текущему.
    func upsert(userId: String, dto: CartDTO, accumulate: Bool)
    
    /// Устанавливает новое количество для конкретного товара.
    /// - Parameters:
    ///   - userId: Идентификатор пользователя.
    ///   - productId: Идентификатор товара.
    ///   - quantity: Новое количество.
    func setQuantity(userId: String, productId: String, quantity: Int)
    
    /// Удаляет товар из корзины.
    /// - Parameters:
    ///   - userId: Идентификатор пользователя.
    ///   - productId: Идентификатор удаляемого товара.
    func remove(userId: String, productId: String)
    
    /// Возвращает текущий снимок корзины пользователя.
    /// - Parameter userId: Идентификатор пользователя.
    /// - Returns: Массив `CartItem` или `nil`, если данных нет.
    func snapshot(userId: String) -> [CartItem]?
    
    /// Полностью очищает корзину пользователя.
    /// - Parameter userId: Идентификатор пользователя.
    func clear(userId: String)
}

