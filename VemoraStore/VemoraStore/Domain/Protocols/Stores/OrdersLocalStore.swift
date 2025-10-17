//
//  OrdersLocalStore.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Combine

/// Протокол `OrdersLocalStore`
///
/// Определяет интерфейс для **локального хранения и наблюдения заказов пользователя**.
///
/// Основные задачи:
/// - реактивное наблюдение за изменениями заказов (`observeOrders`);
/// - синхронизация локальных данных с удалёнными (`replaceAll`, `upsert`);
/// - обновление статуса заказа (`updateStatus`);
/// - очистка локального хранилища заказов (`clear`).
///
/// Используется в:
/// - `OrdersRepository` для кэширования и синхронизации заказов между сетью и локальным слоем (`CoreData`, `Realm` и др.);

protocol OrdersLocalStore: AnyObject {
    
    /// Наблюдает за изменениями заказов пользователя.
    /// - Parameter userId: Идентификатор пользователя.
    /// - Returns: Паблишер, который эмитирует массив `OrderEntity` при изменениях.
    func observeOrders(userId: String) -> AnyPublisher<[OrderEntity], Never>
    
    /// Полностью заменяет локальные данные заказов новыми DTO.
    /// - Parameters:
    ///   - userId: Идентификатор пользователя.
    ///   - dtos: Новый список заказов.
    func replaceAll(userId: String, with dtos: [OrderDTO])
    
    /// Добавляет или обновляет заказ в локальном хранилище.
    /// - Parameters:
    ///   - userId: Идентификатор пользователя.
    ///   - dto: Обновляемый или новый заказ.
    func upsert(userId: String, dto: OrderDTO)
    
    /// Обновляет статус заказа.
    /// - Parameters:
    ///   - userId: Идентификатор пользователя.
    ///   - orderId: Идентификатор заказа.
    ///   - status: Новый статус (`OrderStatus`).
    func updateStatus(userId: String, orderId: String, status: OrderStatus)
    
    /// Очищает локальные данные заказов пользователя.
    /// - Parameter userId: Идентификатор пользователя.
    func clear(userId: String)
}
