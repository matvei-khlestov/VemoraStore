//
//  OrdersRepository.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Combine

/// Протокол `OrdersRepository`
///
/// Определяет единый интерфейс для работы с заказами, объединяя
/// локальные (`OrdersLocalStore`) и удалённые (`OrdersCollectingProtocol`)
/// источники данных.
///
/// Основные задачи:
/// - получение актуального состояния заказов (`observeOrders`);
/// - синхронизация данных между локальным и удалённым хранилищем (`refresh`);
/// - создание новых заказов (`create`);
/// - обновление статуса заказов (`updateStatus`);
/// - очистка локального состояния (`clear`).
///
/// Используется в:
/// - `OrdersViewModel` для отображения истории заказов и обновления их статусов;
/// - `CheckoutViewModel` для создания заказа после оформления покупки;
///
/// Репозиторий инкапсулирует бизнес-логику синхронизации и работает
/// с асинхронными источниками данных (через `Combine` и `async/await`).

protocol OrdersRepository: AnyObject {
    
    // MARK: - Streams
    
    /// Наблюдает за локальными изменениями списка заказов.
    /// - Returns: Паблишер, эмитирующий массив сущностей `OrderEntity`.
    func observeOrders() -> AnyPublisher<[OrderEntity], Never>
    
    // MARK: - Commands
    
    /// Обновляет локальные данные заказов, синхронизируя их с удалённым хранилищем.
    /// - Parameter uid: Идентификатор пользователя.
    func refresh(uid: String) async throws
    
    /// Создаёт новый заказ в удалённом хранилище.
    /// - Parameter order: DTO заказа для создания.
    func create(order: OrderDTO) async throws
    
    /// Обновляет статус конкретного заказа.
    /// - Parameters:
    ///   - orderId: Идентификатор заказа.
    ///   - status: Новый статус.
    func updateStatus(orderId: String, to status: OrderStatus) async throws
    
    /// Полностью очищает локальное состояние заказов (например, при выходе из профиля).
    func clear() async throws
    
    // MARK: - Checkout
    
    /// Создаёт заказ из данных Checkout.
    /// Важно: это требование протокола, чтобы в тестах спай мог перехватывать вызов.
    func createOrderFromCheckout(
        userId: String,
        items: [CartItem],
        deliveryMethod: CheckoutViewModel.DeliveryMethod,
        addressString: String?,
        phoneE164: String?,
        comment: String?
    ) async throws -> String
}
