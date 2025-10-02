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
    private let phoneFormatter: PhoneFormattingProtocol

    // MARK: - State
    
    @Published private(set) var items: [CartItem] = []
    @Published var address: Address? = nil
    @Published private(set) var deliveryAddressString: String? = nil
    @Published var note: String = ""
    @Published private(set) var isPlacing: Bool = false
    @Published private(set) var placeError: String? = nil

    // Телефон получателя: храним E.164 + считаем display
    @Published private(set) var receiverPhoneE164: String? = nil
    @Published private(set) var receiverPhoneDisplay: String? = nil

    // Комментарий к заказу
    @Published private(set) var orderCommentText: String? = nil

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

    /// E.164
    var receiverPhonePublisher: AnyPublisher<String?, Never> {
        $receiverPhoneE164.eraseToAnyPublisher()
    }

    /// Отформатированный для UI
    var receiverPhoneDisplayPublisher: AnyPublisher<String?, Never> {
        $receiverPhoneDisplay.eraseToAnyPublisher()
    }

    var orderCommentPublisher: AnyPublisher<String?, Never> {
        $orderCommentText.eraseToAnyPublisher()
    }

    // MARK: - Outputs
    
    var isPlaceOrderEnabled: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest4(
            $items.map { !$0.isEmpty },
            $deliveryMethod,
            Publishers.CombineLatest($address, $deliveryAddressString),
            $receiverPhoneE164
        )
        .map { hasItems, method, pair, phone -> Bool in
            let (addrModel, addrString) = pair
            let hasDeliveryAddress = (addrModel != nil) || ((addrString ?? "").isEmpty == false)
            let hasPhone = (phone ?? "").isEmpty == false

            switch method {
            case .pickup:
                // самовывоз → телефон обязателен, адрес не нужен
                return hasItems && hasPhone
            case .delivery:
                // доставка → нужен и адрес, и телефон
                return hasItems && hasDeliveryAddress && hasPhone
            }
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    private var bag = Set<AnyCancellable>()

    // MARK: - Init
    init(
        cart: CartServiceProtocol,
        auth: AuthServiceProtocol,
        phoneFormatter: PhoneFormattingProtocol
    ) {
        self.cartService = cart
        self.authService = auth
        self.phoneFormatter = phoneFormatter
        bind()
    }

    // MARK: - Private
    
    private func bind() {
        cartService.itemsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.items = $0 }
            .store(in: &bag)
        
        $receiverPhoneE164
            .removeDuplicates()
            .map { [phoneFormatter] e164 in
                phoneFormatter.displayFromE164(e164)
            }
            .removeDuplicates()                 
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.receiverPhoneDisplay = $0
            }
            .store(in: &bag)

        // Пример автозагрузки телефона из профиля, если нужно:
        /*
        authService.currentUserPhonePublisher
            .first()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.receiverPhoneE164 = $0 }
            .store(in: &bag)
        */
    }

    // MARK: - Actions

    func setDeliveryMethod(_ method: DeliveryMethod) {
        deliveryMethod = method
    }

    func placeOrder() {
        guard !items.isEmpty else { return }
        isPlacing = true
        placeError = nil

        Task {
            try? await Task.sleep(nanoseconds: 600_000_000)
            await MainActor.run { [weak self] in
                self?.isPlacing = false
                // self?.cartService.clear()
            }
        }
    }
    
    func loadMocks() {
        cartService.loadMocks()
    }

    func updateDeliveryAddress(_ fullAddress: String) {
        deliveryAddressString = fullAddress
        if deliveryMethod != .delivery {
            deliveryMethod = .delivery
        }
    }

    // Обновляем E.164; display обновится автоматически через bind()
    func updateReceiverPhone(_ e164: String?) {
        receiverPhoneE164 = (e164?.isEmpty == true) ? nil : e164
    }

    func updateOrderComment(_ text: String?) {
        orderCommentText = (text?.isEmpty == true) ? nil : text
    }
}
