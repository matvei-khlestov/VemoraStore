//
//  CartViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

final class CartViewModel: CartViewModelProtocol {
    // MARK: - Deps
    private let repo: CartRepository
    
    // MARK: - State
    @Published private(set) var cartItems: [CartItem] = []
    var cartItemsPublisher: AnyPublisher<[CartItem], Never> {
        $cartItems.eraseToAnyPublisher()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    /// Передаём сюда реализацию `DefaultCartRepository`
    init(cartRepository: CartRepository) {
        self.repo = cartRepository
        bind()
    }
    
    private func bind() {
        // Реальные данные: CoreData ←(sync)— Firestore
        repo.observeItems()
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
        cartItems.reduce(0) { $0 + $1.lineTotal }
    }
    
    func setQuantity(for productId: String, quantity: Int) {
        let newQty = max(1, quantity)
        Task { try? await repo.setQuantity(productId: productId, quantity: newQty) }
        // оптимистичное обновление до прихода снапшота
        if let idx = cartItems.firstIndex(where: { $0.productId == productId }) {
            cartItems[idx].quantity = newQty
        }
    }
    
    func increaseQuantity(for productId: String) {
        let current = cartItems.first(where: { $0.productId == productId })?.quantity ?? 0
        Task { try? await repo.setQuantity(productId: productId, quantity: current + 1) }
    }
    
    func decreaseQuantity(for productId: String) {
        let current = cartItems.first(where: { $0.productId == productId })?.quantity ?? 0
        let newQty = max(1, current - 1)
        Task { try? await repo.setQuantity(productId: productId, quantity: newQty) }
    }
    
    func removeItem(with productId: String) {
        Task { try? await repo.remove(productId: productId) }
        if let idx = cartItems.firstIndex(where: { $0.productId == productId }) {
            cartItems.remove(at: idx) // оптимистично
        }
    }
    
    func clearCart() {
        Task { try? await repo.clear() }
        cartItems.removeAll()
    }
}
