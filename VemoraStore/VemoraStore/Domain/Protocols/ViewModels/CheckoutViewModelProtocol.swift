//
//  CheckoutViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 17.09.2025.
//

import Foundation
import Combine

protocol CheckoutViewModelProtocol: AnyObject {
    // MARK: - Publishers (для bind в VC)
    var deliveryMethodPublisher: AnyPublisher<CheckoutViewModel.DeliveryMethod, Never> { get }
    var deliveryAddressStringPublisher: AnyPublisher<String?, Never> { get }
    var isPlaceOrderEnabled: AnyPublisher<Bool, Never> { get }

    // MARK: - State (read-only)
    var deliveryMethod: CheckoutViewModel.DeliveryMethod { get }
    var deliveryAddressString: String? { get }

    // MARK: - Intents
    func setDeliveryMethod(_ method: CheckoutViewModel.DeliveryMethod)
    func updateDeliveryAddress(_ fullAddress: String)
    func placeOrder()
    func loadMocks()
}
