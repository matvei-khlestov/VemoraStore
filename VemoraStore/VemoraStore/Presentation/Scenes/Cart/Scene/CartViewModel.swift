//
//  CartViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

/// ViewModel `CartViewModel` для экрана корзины.
///
/// Основные задачи:
/// - Наблюдение за позициями корзины через `CartRepository` и публикация `cartItemsPublisher`;
/// - Изменение количества/удаление товаров и полная очистка корзины;
/// - Подсчёт агрегатов (`totalItems`, `totalPrice`);
/// - Форматирование цен через `PriceFormattingProtocol`;
/// - Планирование и отмена локального напоминания о «брошенной» корзине (`LocalNotifyingProtocol`).
///
/// Реактивность:
/// - Обновления состояния доставляются на главный поток, подписки управляются через Combine;
/// - Напоминание автоматически отменяется, когда корзина становится пустой.

final class CartViewModel: CartViewModelProtocol {
    
    // MARK: - Deps
    
    private let repo: CartRepository
    private let priceFormatter: PriceFormattingProtocol
    private let notifier: LocalNotifyingProtocol
    
    // MARK: - State
    
    @Published private(set) var cartItems: [CartItem] = []
    var cartItemsPublisher: AnyPublisher<[CartItem], Never> {
        $cartItems.eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    /// Передаём сюда реализацию `DefaultCartRepository`
    init(
        cartRepository: CartRepository,
        priceFormatter: PriceFormattingProtocol,
        notifier: LocalNotifyingProtocol
    ) {
        self.repo = cartRepository
        self.priceFormatter = priceFormatter
        self.notifier = notifier
        bind()
    }
    
    private func bind() {
        repo.observeItems()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.cartItems = items
            }
            .store(in: &cancellables)
        $cartItems
            .map { items in items.reduce(0) {
                $0 + $1.quantity
            } }
            .removeDuplicates()
            .sink { [weak self] total in
                guard let self else { return }
                if total == 0 {
                    self.cancelCartReminder()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public API
    
    var count: Int {
        cartItems.count
    }
    
    func item(at indexPath: IndexPath) -> CartItem {
        cartItems[indexPath.row]
    }
    
    var totalItems: Int {
        cartItems.reduce(0) {
            $0 + $1.quantity
        }
    }
    
    var totalPrice: Double {
        cartItems.reduce(0) {
            $0 + $1.lineTotal
        }
    }
    
    func setQuantity(for productId: String, quantity: Int) {
        let newQty = max(1, quantity)
        Task {
            try? await repo.setQuantity(
                productId: productId,
                quantity: newQty
            )
        }
        
        if let idx = cartItems.firstIndex(where: {
            $0.productId == productId
        }) {
            cartItems[idx].quantity = newQty
        }
    }
    
    func increaseQuantity(for productId: String) {
        let current = cartItems.first(where: {
            $0.productId == productId
        })?.quantity ?? 0
        Task { try? await repo.setQuantity(
            productId: productId,
            quantity: current + 1)
        }
    }
    
    func decreaseQuantity(for productId: String) {
        let current = cartItems.first(where: {
            $0.productId == productId
        })?.quantity ?? 0
        
        let newQty = max(1, current - 1)
        Task {
            try? await repo.setQuantity(
                productId: productId,
                quantity: newQty
            )
        }
    }
    
    func removeItem(with productId: String) {
        Task { try? await repo.remove(productId: productId) }
        if let idx = cartItems.firstIndex(where: {
            $0.productId == productId
        }) {
            cartItems.remove(at: idx)
        }
    }
    
    // MARK: - Local Notifications

    func scheduleCartReminderForLeavingScreen() {
        guard totalItems > 0 else {
            cancelCartReminder()
            return
        }
    #if DEBUG
        _ = notifier.schedule(
            after: 10,
            id: NotificationTemplate.Cart.id,
            title: NotificationTemplate.Cart.title,
            body: NotificationTemplate.Cart.body,
            categoryId: NotificationTemplate.Cart.categoryId,
            userInfo: NotificationTemplate.Cart.userInfo,
            unique: true
        )
    #else
        _ = notifier.schedule(
            after: 2 * 60 * 60,
            id: NotificationTemplate.Cart.id,
            title: NotificationTemplate.Cart.title,
            body: NotificationTemplate.Cart.body,
            categoryId: NotificationTemplate.Cart.categoryId,
            userInfo: NotificationTemplate.Cart.userInfo,
            unique: true
        )
    #endif
    }
    
   private func cancelCartReminder() {
        notifier.cancel(ids: [NotificationTemplate.Cart.id])
    }
    
    // MARK: - Checkout Actions

    func clearCart() {
        Task {
            try? await repo.clear()
        }
        cancelCartReminder()
        cartItems.removeAll()
    }
    
    func formattedPrice(_ price: Double) -> String {
        priceFormatter.format(price: price)
    }
}
