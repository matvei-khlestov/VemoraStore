//
//  DefaultOrdersRepository.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Foundation
import Combine

/// Класс `DefaultOrdersRepository` — реализация репозитория заказов.
///
/// Назначение:
/// - объединяет работу локального (`OrdersLocalStore`) и удалённого (`OrdersCollectingProtocol`) источников данных;
/// - обеспечивает синхронизацию заказов между Firestore и Core Data;
/// - предоставляет реактивное наблюдение за заказами и операции управления ими.
///
/// Состав:
/// - `remote`: источник заказов из Firestore (чтение, создание, обновление, удаление);
/// - `local`: локальное хранилище заказов для офлайн-доступа и отображения в UI;
/// - `userId`: текущий идентификатор пользователя;
/// - `ordersSubject`: паблишер для стриминга актуального списка заказов в реальном времени.
///
/// Основные функции:
/// - `observeOrders()` — наблюдение за заказами текущего пользователя через Combine;
/// - `refresh(uid:)` — принудительное обновление локального состояния из Firestore;
/// - `create(order:)` — создание нового заказа с подстраховкой локального апдейта;
/// - `updateStatus(orderId:to:)` — обновление статуса заказа локально и в Firestore;
/// - `clear()` — полная очистка заказов пользователя локально и в облаке.
///
/// Особенности реализации:
/// - использует `Combine` для синхронизации данных между слоями;
/// - при изменении заказов в Firestore автоматически обновляет локальное хранилище;
/// - дополнительно содержит расширение `createOrderFromCheckout()`
///   — вспомогательный метод для удобного формирования заказа из данных экрана Checkout.

final class DefaultOrdersRepository: OrdersRepository {
    
    // MARK: - Deps
    
    private let remote: OrdersCollectingProtocol
    private let local: OrdersLocalStore
    private let userId: String
    
    // MARK: - State
    
    private var bag = Set<AnyCancellable>()
    private let ordersSubject = CurrentValueSubject<[OrderEntity], Never>([])
    
    // MARK: - Init
    
    init(remote: OrdersCollectingProtocol,
         local: OrdersLocalStore,
         userId: String) {
        self.remote = remote
        self.local = local
        self.userId = userId
        bindStreams()
    }
    
    // MARK: - Streams
    
    func observeOrders() -> AnyPublisher<[OrderEntity], Never> {
        ordersSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Commands
    
    func refresh(uid: String) async throws {
        let dtos = try await remote.fetchOrders(uid: uid)
        local.replaceAll(userId: userId, with: dtos)
    }
    
    func create(order: OrderDTO) async throws {
        try await remote.createOrder(uid: userId, dto: order)
        local.upsert(userId: userId, dto: order)
    }
    
    func updateStatus(orderId: String, to status: OrderStatus) async throws {
        try await remote.updateStatus(
            uid: userId,
            orderId: orderId,
            status: status
        )
        local.updateStatus(
            userId: userId,
            orderId: orderId,
            status: status
        )
    }
    
    func clear() async throws {
        try await remote.clear(uid: userId)
        local.clear(userId: userId)
    }
}

// MARK: - Private

private extension DefaultOrdersRepository {
    func bindStreams() {
        local.observeOrders(userId: userId)
            .subscribe(ordersSubject)
            .store(in: &bag)
        
        remote.listenOrders(uid: userId)
            .sink { [weak self] dtos in
                guard let self else { return }
                self.local.replaceAll(userId: self.userId, with: dtos)
            }
            .store(in: &bag)
    }
}

extension OrdersRepository {
    @discardableResult
    func createOrderFromCheckout(
        userId: String,
        items: [CartItem],
        deliveryMethod: CheckoutViewModel.DeliveryMethod,
        addressString: String?,
        phoneE164: String?,
        comment: String?
    ) async throws -> String {
        let receiveAddress: String = {
            switch deliveryMethod {
            case .pickup:   return "Пункт самовывоза"
            case .delivery: return addressString ?? ""
            }
        }()
        
        let orderItems = items.map {
            OrderItemDTO(
                productId: $0.productId,
                brandName: $0.brandName,
                title:     $0.title,
                price:     $0.price,
                imageURL:  $0.imageURL,
                quantity:  $0.quantity
            )
        }
        
        let now = Date()
        let id = UUID().uuidString
        let dto = OrderDTO(
            id: id,
            userId: userId,
            createdAt: now,
            updatedAt: now,
            status: .assembling,
            receiveAddress: receiveAddress,
            paymentMethod: "При получении",
            comment: comment,
            phoneE164: phoneE164,
            items: orderItems
        )
        
        try await create(order: dto)
        return id
    }
}
