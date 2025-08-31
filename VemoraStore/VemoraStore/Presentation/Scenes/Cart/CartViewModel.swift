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

    // MARK: - State
    @Published private(set) var items: [CartItemEntity] = []
    private var cancellables = Set<AnyCancellable>()

    // Доп. output: общая сумма корзины
    var totalPublisher: AnyPublisher<Double, Never> {
        cartService.itemsPublisher
            .map { $0.reduce(0) { $0 + $1.totalPrice } }
            .eraseToAnyPublisher()
    }

    // MARK: - Init
    init(cartService: CartServiceProtocol = Container.shared.cartService()) {
        self.cartService = cartService
        bind()
    }

    // MARK: - Private
    private func bind() {
        cartService.itemsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.items = $0 }
            .store(in: &cancellables)
    }

    // MARK: - Actions (пробрасываем в сервис)
    func add(product: Product) {
        cartService.add(product: product)
    }

    func remove(id: String) {
        cartService.remove(id: id)
    }

    func changeQuantity(id: String, qty: Int) {
        cartService.changeQuantity(id: id, qty: qty)
    }

    func clear() {
        cartService.clear()
    }

    func total() -> Double {
        cartService.total()
    }
}
