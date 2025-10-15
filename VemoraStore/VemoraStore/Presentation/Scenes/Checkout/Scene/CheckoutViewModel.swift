//
//  CheckoutViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

final class CheckoutViewModel: CheckoutViewModelProtocol {
    
    // MARK: - Deps
    
    private let cartRepository: CartRepository
    private let ordersRepository: OrdersRepository
    private let phoneFormatter: PhoneFormattingProtocol
    private let priceFormatter: PriceFormattingProtocol
    private let notifier: LocalNotifyingProtocol
    private var storage: CheckoutStoringProtocol
    private let currentUserId: String
    
    // MARK: - State
    
    @Published private(set) var items: [CartItem] = []
    @Published var address: Address? = nil
    @Published private(set) var deliveryAddressString: String? = nil
    @Published private(set) var isPlacing: Bool = false
    @Published private(set) var receiverPhoneE164: String? = nil
    @Published private(set) var receiverPhoneDisplay: String? = nil
    @Published private(set) var orderCommentText: String? = nil
    
    enum DeliveryMethod { case pickup, delivery }
    @Published var deliveryMethod: DeliveryMethod = .pickup
    
    // MARK: - Publishers
    
    var deliveryMethodPublisher: AnyPublisher<DeliveryMethod, Never> {
        $deliveryMethod.eraseToAnyPublisher()
    }
    
    var deliveryAddressStringPublisher: AnyPublisher<String?, Never> {
        $deliveryAddressString.eraseToAnyPublisher()
        
    }
    
    var receiverPhoneDisplayPublisher: AnyPublisher<String?, Never> {
        $receiverPhoneDisplay.eraseToAnyPublisher()
    }
    
    var orderCommentPublisher: AnyPublisher<String?, Never> {
        $orderCommentText.eraseToAnyPublisher()
    }
    
    var itemsPublisher: AnyPublisher<[CartItem], Never> {
        $items.eraseToAnyPublisher()
    }
    
    var itemsSnapshot: [CartItem] {
        items
    }
    
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
            case .pickup:   return hasItems
            case .delivery: return hasItems && hasDeliveryAddress && hasPhone
            }
        }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
    
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(
        cartRepository: CartRepository,
        ordersRepository: OrdersRepository,
        phoneFormatter: PhoneFormattingProtocol,
        priceFormatter: PriceFormattingProtocol,
        snapshotItems: [CartItem],
        storage: CheckoutStoringProtocol,
        currentUserId: String,
        notifier: LocalNotifyingProtocol
    ) {
        self.cartRepository = cartRepository
        self.ordersRepository = ordersRepository
        self.phoneFormatter = phoneFormatter
        self.priceFormatter = priceFormatter
        self.items = snapshotItems
        self.storage = storage
        self.currentUserId = currentUserId
        self.notifier = notifier
        
        switch storage.savedDeliveryMethod {
        case .pickup:   self.deliveryMethod = .pickup
        case .delivery: self.deliveryMethod = .delivery
        }
        
        self.deliveryAddressString = storage.savedDeliveryAddressString
        self.receiverPhoneE164 = storage.savedReceiverPhoneE164
        
        cartRepository.observeItems()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.items = items
            }
            .store(in: &bag)
        
        bind()
    }
    
    // MARK: - Binding
    
    private func bind() {
        $receiverPhoneE164
            .removeDuplicates()
            .map { [phoneFormatter] e164 in phoneFormatter.displayFromE164(e164) }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.receiverPhoneDisplay = $0 }
            .store(in: &bag)
        
        $deliveryMethod
            .removeDuplicates {
                ($0 == .pickup && $1 == .pickup) || ($0 == .delivery && $1 == .delivery)
            }
            .sink { [weak self] method in
                guard let self else { return }
                self.storage.savedDeliveryMethod = (method == .pickup) ? .pickup : .delivery
            }
            .store(in: &bag)
        
        $deliveryAddressString
            .removeDuplicates()
            .sink { [weak self] value in
                self?.storage.savedDeliveryAddressString = value
            }
            .store(in: &bag)
        
        $receiverPhoneE164
            .removeDuplicates()
            .sink { [weak self] value in
                self?.storage.savedReceiverPhoneE164 = value
            }
            .store(in: &bag)
    }
    
    // MARK: - Intents
    
    func setDeliveryMethod(_ method: DeliveryMethod) {
        deliveryMethod = method
    }
    
    func placeOrder() async throws {
        try validateBeforePlacing()

        isPlacing = true
        defer {
            isPlacing = false
        }

        do {
            _ = try await ordersRepository.createOrderFromCheckout(
                userId: currentUserId,
                items: items,
                deliveryMethod: deliveryMethod,
                addressString: deliveryAddressString,
                phoneE164: receiverPhoneE164,
                comment: orderCommentText
            )
            schedulePostOrderNotification()
        } catch {
            throw AppError.map(error)
        }
    }
    
    func clearCart() async {
        try? await cartRepository.clear()
    }
    
    func updateDeliveryAddress(_ fullAddress: String) {
        deliveryAddressString = fullAddress
        storage.savedDeliveryAddressString = fullAddress
        if deliveryMethod != .delivery { deliveryMethod = .delivery }
    }
    
    func updateReceiverPhone(_ e164: String?) {
        let value = (e164?.isEmpty == true) ? nil : e164
        receiverPhoneE164 = value
        storage.savedReceiverPhoneE164 = value
    }
    
    func updateOrderComment(_ text: String?) {
        orderCommentText = (text?.isEmpty == true) ? nil : text
    }
    
    func formattedTotalPrice(from items: [CartItem]) -> String {
        let totalPrice = items.reduce(0.0) { $0 + $1.lineTotal }
        return formattedPrice(totalPrice)
    }
    
    func formattedPrice(_ price: Double) -> String {
        priceFormatter.format(price: price)
    }
}

private extension CheckoutViewModel {
    // MARK: - Helpers
    
    /// Валидация данных перед оформлением заказа.
    /// - Returns: `AppError`, если есть проблемы, иначе `nil`.
    private func validateBeforePlacing() throws {
        if items.isEmpty {
            throw AppError.emptyCart
        }

        if deliveryMethod == .delivery {
            let hasAddress = !(deliveryAddressString ?? "").isEmpty
            let hasPhone   = !(receiverPhoneE164 ?? "").isEmpty
            guard hasAddress && hasPhone else {
                throw AppError.missingRequiredFields
            }
        }
    }
    
    /// Планирует локальное уведомление в зависимости от способа получения.
    private func schedulePostOrderNotification() {
        // если ты ещё не внедрил `notifier` в VM — просто убери этот метод/вызов
        switch deliveryMethod {
        case .pickup:
            _ = notifier.schedule(
                after: 1,
                id: NotificationTemplate.Checkout.Pickup.id,
                title: NotificationTemplate.Checkout.Pickup.title,
                body: NotificationTemplate.Checkout.Pickup.body,
                categoryId: NotificationTemplate.Checkout.Pickup.categoryId,
                userInfo: NotificationTemplate.Checkout.Pickup.userInfo,
                unique: true
            )
        case .delivery:
            _ = notifier.schedule(
                after: 1,
                id: NotificationTemplate.Checkout.Delivery.id,
                title: NotificationTemplate.Checkout.Delivery.title,
                body: NotificationTemplate.Checkout.Delivery.body,
                categoryId: NotificationTemplate.Checkout.Delivery.categoryId,
                userInfo: NotificationTemplate.Checkout.Delivery.userInfo,
                unique: true
            )
        }
    }
}
