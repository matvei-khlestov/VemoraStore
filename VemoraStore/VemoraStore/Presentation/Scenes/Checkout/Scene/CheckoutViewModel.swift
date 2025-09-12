//
//  CheckoutViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine
import FactoryKit

final class CheckoutViewModel {

    // MARK: - Services
    private let cartService: CartServiceProtocol
    private let authService: AuthServiceProtocol

    // MARK: - State
    @Published private(set) var items: [CartItemEntity] = []
    @Published var address: Address? = nil          // выбранный адрес доставки (или nil для самовывоза)
    @Published var note: String = ""                // комментарий к заказу
    @Published private(set) var isPlacing: Bool = false
    @Published private(set) var placeError: String? = nil

    // Способ получения заказа
    enum DeliveryMethod { case pickup, delivery }
    @Published var deliveryMethod: DeliveryMethod = .pickup

    // MARK: - Outputs
//    var totalPublisher: AnyPublisher<Double, Never> {
//        cartService.itemsPublisher
//            .map { $0.reduce(into: 0) { $0 + $1.totalPrice } }
//            .eraseToAnyPublisher()
//    }

    /// Можно ли оформить заказ (есть товары и либо самовывоз, либо есть адрес)
    var isPlaceOrderEnabled: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($items.map { !$0.isEmpty },
                                 Publishers.CombineLatest($deliveryMethod, $address)
                                    .map { method, addr in method == .pickup || addr != nil })
        .map { hasItems, hasFulfillment in hasItems && hasFulfillment }
        .eraseToAnyPublisher()
    }

    private var bag = Set<AnyCancellable>()

    // MARK: - Init
    init(
        cart: CartServiceProtocol = Container.shared.cartService(),
        auth: AuthServiceProtocol = Container.shared.authService()
    ) {
        self.cartService = cart
        self.authService = auth
        bind()
    }

    // MARK: - Private
    private func bind() {
//        cartService.itemsPublisher
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] in self?.items = $0 }
//            .store(in: &bag)
    }

    // MARK: - Actions
    func selectAddress(_ address: Address) {
        self.address = address
    }

    func setDeliveryMethod(_ method: DeliveryMethod) {
        deliveryMethod = method
        if method == .pickup { address = nil }
    }

    /// Оформление заказа (оплата при получении)
    func placeOrder() {
        guard !items.isEmpty else { return }
        isPlacing = true
        placeError = nil

        // Заглушка: имитация успешного оформления
        Task {
            try? await Task.sleep(nanoseconds: 600_000_000) // 0.6s
            await MainActor.run { [weak self] in
                self?.isPlacing = false
                /*self?.cartService.clear()*/ // очистим корзину после "успеха"
            }
        }
    }
    
    func loadMocks() {
        cartService.loadMocks()
    }
}
