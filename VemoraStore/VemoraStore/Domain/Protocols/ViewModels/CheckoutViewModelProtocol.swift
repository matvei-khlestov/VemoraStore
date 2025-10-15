//
//  CheckoutViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 17.09.2025.
//

import Combine

protocol CheckoutViewModelProtocol: AnyObject {

    // MARK: - Publishers (для bind в VC)
    
    var deliveryMethodPublisher: AnyPublisher<CheckoutViewModel.DeliveryMethod, Never> { get }
    var deliveryAddressStringPublisher: AnyPublisher<String?, Never> { get }
    var receiverPhoneDisplayPublisher: AnyPublisher<String?, Never> { get }
    var orderCommentPublisher: AnyPublisher<String?, Never> { get }
    var itemsPublisher: AnyPublisher<[CartItem], Never> { get }
    var isPlaceOrderEnabled: AnyPublisher<Bool, Never> { get }

    // MARK: - State (read-only)
    
    var deliveryMethod: CheckoutViewModel.DeliveryMethod { get }
    var deliveryAddressString: String? { get }
    var receiverPhoneE164: String? { get }
    var orderCommentText: String? { get }
    var receiverPhoneDisplay: String? { get }
    var itemsSnapshot: [CartItem] { get }

    // MARK: - Intents
    
    func setDeliveryMethod(_ method: CheckoutViewModel.DeliveryMethod)
    func updateDeliveryAddress(_ fullAddress: String)
    func updateReceiverPhone(_ e164: String?)
    func updateOrderComment(_ text: String?)
    func placeOrder(completion: @escaping (Result<Void, Error>) -> Void)
    func formattedTotalPrice(from items: [CartItem]) -> String
    func formattedPrice(_ price: Double) -> String
    func clearCart() async
}
