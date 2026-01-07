//
//  AnalyticsEvent.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 07.01.2026.
//

import Foundation

enum AnalyticsEvent {

    // MARK: - Favorites

    case favoriteToggle(productId: String, isFavorite: Bool)
    case favoritesClear(count: Int)

    // MARK: - Cart

    case cartAdd(productId: String, quantity: Int, price: Double?)
    case cartRemove(productId: String)
    case cartQuantityChange(productId: String, quantity: Int)
    case cartClear(count: Int, totalPrice: Double)

    // MARK: - Checkout

    case beginCheckout(itemsCount: Int, totalPrice: Double, currency: String)
    case setDeliveryMethod(method: String) // "pickup" | "delivery"
    case setDeliveryAddress(isEmpty: Bool)
    case setReceiverPhone(isEmpty: Bool)

    case placeOrderTap(itemsCount: Int, totalPrice: Double, currency: String, method: String)
    case orderCreated(orderId: String?, itemsCount: Int, totalPrice: Double, currency: String, method: String)
    case orderCreateFailed(reason: String, method: String)
}
