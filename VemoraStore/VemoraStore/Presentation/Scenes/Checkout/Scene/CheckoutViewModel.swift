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
        currentUserId: String
    ) {
        self.cartRepository = cartRepository
        self.ordersRepository = ordersRepository
        self.phoneFormatter = phoneFormatter
        self.priceFormatter = priceFormatter
        self.items = snapshotItems            // ⚡ мгновенный рендер из снапшота
        self.storage = storage
        self.currentUserId = currentUserId
        
        switch storage.savedDeliveryMethod {
        case .pickup:   self.deliveryMethod = .pickup
        case .delivery: self.deliveryMethod = .delivery
        }
        
        self.deliveryAddressString = storage.savedDeliveryAddressString
        self.receiverPhoneE164 = storage.savedReceiverPhoneE164

        // ✅ ВАЖНО: начинаем слушать живую корзину
        cartRepository.observeItems()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.items = items              // экран автоматически обновится
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
    
    func placeOrder(completion: @escaping (Result<Void, Error>) -> Void) {
        guard !items.isEmpty else {
            completion(.failure(NSError(domain: "Checkout", code: 1,
                                        userInfo: [NSLocalizedDescriptionKey: "Корзина пуста"])))
            return
        }
        
        if deliveryMethod == .delivery {
            let hasAddress = ((deliveryAddressString ?? "").isEmpty == false)
            let hasPhone   = ((receiverPhoneE164 ?? "").isEmpty == false)
            guard hasAddress && hasPhone else {
                completion(.failure(NSError(domain: "Checkout", code: 2,
                                            userInfo: [NSLocalizedDescriptionKey: "Укажите адрес и телефон"])))
                return
            }
        }
        
        isPlacing = true
        Task {
            do {
                _ = try await ordersRepository.createOrderFromCheckout(
                    userId: currentUserId,
                    items: items,
                    deliveryMethod: deliveryMethod,
                    addressString: deliveryAddressString,
                    phoneE164: receiverPhoneE164,
                    comment: orderCommentText
                )
                await MainActor.run {
                    self.isPlacing = false
                    completion(.success(()))
                }
            } catch {
                await MainActor.run {
                    self.isPlacing = false
                    completion(.failure(error))
                }
            }
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
