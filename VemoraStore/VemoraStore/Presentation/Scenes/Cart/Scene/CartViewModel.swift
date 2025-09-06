//
//  CartViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine
import FactoryKit

final class CartViewModel {

    // MARK: - Services
    private let cartService: CartServiceProtocol

    // MARK: - State (Outputs for Controller)
    @Published private(set) var cartItems: [CartItem] = []

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(
        cartService: CartServiceProtocol = Container.shared.cartService()
    ) {
        self.cartService = cartService
        bind()
    }

    private func bind() {
        // Подписываемся на изменения корзины из сервиса
        cartService.itemsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.cartItems = items
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API (для контроллера)

    /// Кол-во строк в таблице
    var count: Int { cartItems.count }

    func item(at indexPath: IndexPath) -> CartItem { cartItems[indexPath.row] }

    /// Суммарное количество единиц
    var totalItems: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }

    /// Итоговая стоимость (в ваших единицах Product.price)
    var totalPrice: Double {
        cartItems.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
    }

    // Количество

    func setQuantity(for productId: String, quantity: Int) {
        let newQty = max(1, quantity)
        cartService.setQuantity(productId: productId, quantity: newQty)
        // Оптимистичное обновление UI (не обязательно, если сервис быстро шлёт itemsPublisher)
        if let idx = cartItems.firstIndex(where: { $0.id == productId }) {
            cartItems[idx].quantity = newQty
        }
    }

    func increaseQuantity(for productId: String) {
        cartService.increase(productId: productId)
        if let idx = cartItems.firstIndex(where: { $0.id == productId }) {
            cartItems[idx].quantity += 1
        }
    }

    func decreaseQuantity(for productId: String) {
        cartService.decrease(productId: productId)
        if let idx = cartItems.firstIndex(where: { $0.id == productId }) {
            cartItems[idx].quantity = max(1, cartItems[idx].quantity - 1)
        }
    }

    /// Удаление позиции по индексу
    func removeItem(at index: Int) {
        guard cartItems.indices.contains(index) else { return }
        let removed = cartItems[index]
        cartService.remove(productId: removed.id)
        cartItems.remove(at: index) // оптимистично
    }

    /// Удаление по productId
    func removeItem(with productId: String) {
        cartService.remove(productId: productId)
        if let idx = cartItems.firstIndex(where: { $0.id == productId }) {
            cartItems.remove(at: idx) // оптимистично
        }
    }

    // MARK: - Mocks / Bootstrap

    /// Быстрая загрузка мок-данных через сервис (если он это поддерживает)
    func loadMocks() {
        cartService.loadMocks()
    }
}
