//
//  CartViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

final class CartViewModel: CartViewModelProtocol {
    // MARK: - Services
    private let cartService: CartServiceProtocol

    // MARK: - State
    @Published private(set) var cartItems: [CartItem] = []
    var cartItemsPublisher: AnyPublisher<[CartItem], Never> {
        $cartItems.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(cartService: CartServiceProtocol) {
        self.cartService = cartService
        bind()
    }

    private func bind() {
        cartService.itemsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.cartItems = items
            }
            .store(in: &cancellables)
    }

    // MARK: - Public API
    var count: Int { cartItems.count }

    func item(at indexPath: IndexPath) -> CartItem { cartItems[indexPath.row] }

    var totalItems: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }

    var totalPrice: Double {
        cartItems.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
    }

    func setQuantity(for productId: String, quantity: Int) {
        let newQty = max(1, quantity)
        cartService.setQuantity(productId: productId, quantity: newQty)
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

    func removeItem(at index: Int) {
        guard cartItems.indices.contains(index) else { return }
        let removed = cartItems[index]
        cartService.remove(productId: removed.id)
        cartItems.remove(at: index)
    }

    func removeItem(with productId: String) {
        cartService.remove(productId: productId)
        if let idx = cartItems.firstIndex(where: { $0.id == productId }) {
            cartItems.remove(at: idx)
        }
    }

    func loadMocks() {
        cartService.loadMocks()
    }
}
