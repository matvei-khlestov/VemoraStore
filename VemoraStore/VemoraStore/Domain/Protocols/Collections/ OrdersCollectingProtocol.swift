//
//   OrdersCollectingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Foundation
import Combine


/// Протокол `OrdersCollectingProtocol`
///
/// Отвечает за сетевое и реактивное взаимодействие с коллекцией заказов пользователя.
///
/// Основные задачи:
/// - получение списка заказов (`fetchOrders`);
/// - создание нового заказа (`createOrder`);
/// - обновление статуса существующего заказа (`updateStatus`);
/// - реактивное прослушивание изменений (`listenOrders`);
/// - очистка истории заказов (`clear`).
///
/// Используется в:
/// - `OrdersRepository` для синхронизации заказов между сервером и локальным хранилищем;
/// - `OrdersViewModel` для отображения истории заказов и обновлений статусов.

protocol OrdersCollectingProtocol: AnyObject {
    
    /// Загружает список заказов пользователя.
    /// - Parameter uid: Идентификатор пользователя.
    /// - Returns: Список заказов в виде массива `OrderDTO`.
    func fetchOrders(uid: String) async throws -> [OrderDTO]
    
    /// Создаёт новый заказ.
    /// - Parameters:
    ///   - uid: Идентификатор пользователя.
    ///   - dto: DTO создаваемого заказа.
    func createOrder(uid: String, dto: OrderDTO) async throws
    
    /// Обновляет статус существующего заказа.
    /// - Parameters:
    ///   - uid: Идентификатор пользователя.
    ///   - orderId: Идентификатор заказа.
    ///   - status: Новый статус заказа.
    func updateStatus(uid: String, orderId: String, status: OrderStatus) async throws
    
    /// Реактивно слушает изменения в коллекции заказов пользователя.
    /// - Parameter uid: Идентификатор пользователя.
    /// - Returns: Паблишер, эмитирующий актуальный список заказов.
    func listenOrders(uid: String) -> AnyPublisher<[OrderDTO], Never>
    
    /// Очищает историю заказов пользователя.
    /// - Parameter uid: Идентификатор пользователя.
    func clear(uid: String) async throws
}
