//
//  CheckoutViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

final class CheckoutViewModel: CheckoutViewModelProtocol {

    // MARK: - Services
    private let cartService: CartServiceProtocol
    private let authService: AuthServiceProtocol

    // MARK: - State
    @Published private(set) var items: [CartItemEntity] = []
    @Published var address: Address? = nil
    @Published private(set) var deliveryAddressString: String? = nil
    @Published var note: String = ""
    @Published private(set) var isPlacing: Bool = false
    @Published private(set) var placeError: String? = nil

    // Способ получения заказа
    enum DeliveryMethod { case pickup, delivery }
    @Published var deliveryMethod: DeliveryMethod = .pickup

    // MARK: - Publishers (protocol)
    var deliveryMethodPublisher: AnyPublisher<DeliveryMethod, Never> {
        $deliveryMethod.eraseToAnyPublisher()
    }

    var deliveryAddressStringPublisher: AnyPublisher<String?, Never> {
        $deliveryAddressString.eraseToAnyPublisher()
    }

    // MARK: - Outputs
    var isPlaceOrderEnabled: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3(
            $items.map { !$0.isEmpty },
            $deliveryMethod,
            Publishers.CombineLatest($address, $deliveryAddressString)
        )
        .map { hasItems, method, pair -> Bool in
            let (addrModel, addrString) = pair
            let hasDeliveryAddress = (addrModel != nil) || ((addrString ?? "").isEmpty == false)
            let hasFulfillment = (method == .pickup) || hasDeliveryAddress
            return hasItems && hasFulfillment
        }
        .eraseToAnyPublisher()
    }

    private var bag = Set<AnyCancellable>()

    // MARK: - Init
    init(
        cart: CartServiceProtocol,
        auth: AuthServiceProtocol
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

    func setDeliveryMethod(_ method: DeliveryMethod) {
        deliveryMethod = method
        if method == .pickup {
            address = nil
            deliveryAddressString = nil
        }
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

    /// Устанавливает полный адрес строкой (из MapPicker/DeliveryDetails)
    func updateDeliveryAddress(_ fullAddress: String) {
        deliveryAddressString = fullAddress
        // переключаемся на режим доставки, т.к. адрес задан
        if deliveryMethod != .delivery {
            deliveryMethod = .delivery
        }
    }
}
