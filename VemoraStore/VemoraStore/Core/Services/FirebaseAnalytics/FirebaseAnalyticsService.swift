//
//  FirebaseAnalyticsService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 07.01.2026.
//

import Foundation
import FirebaseAnalytics

final class FirebaseAnalyticsService: AnalyticsServiceProtocol {

    func log(_ event: AnalyticsEvent) {
        let (name, params) = map(event)
        Analytics.logEvent(name, parameters: params)
    }

    func setUserId(_ userId: String?) {
        Analytics.setUserID(userId)
    }

    func setUserProperty(_ value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }
}

private extension FirebaseAnalyticsService {

    func map(_ event: AnalyticsEvent) -> (String, [String: Any]) {
        switch event {

        // MARK: - Favorites

        case let .favoriteToggle(productId, isFavorite):
            return ("favorite_toggle", [
                "product_id": productId,
                "is_favorite": isFavorite
            ])

        case let .favoritesClear(count):
            return ("favorites_clear", [
                "count": count
            ])

        // MARK: - Cart

        case let .cartAdd(productId, quantity, price):
            var p: [String: Any] = [
                "product_id": productId,
                "quantity": quantity
            ]
            if let price { p["price"] = price }
            return ("add_to_cart", p)

        case let .cartRemove(productId):
            return ("remove_from_cart", [
                "product_id": productId
            ])

        case let .cartQuantityChange(productId, quantity):
            return ("cart_quantity_change", [
                "product_id": productId,
                "quantity": quantity
            ])

        case let .cartClear(count, totalPrice):
            return ("cart_clear", [
                "count": count,
                "total_price": totalPrice
            ])

        // MARK: - Checkout

        case let .beginCheckout(itemsCount, totalPrice, currency):
            return ("begin_checkout", [
                "items_count": itemsCount,
                "value": totalPrice,
                "currency": currency
            ])

        case let .setDeliveryMethod(method):
            return ("set_delivery_method", [
                "method": method
            ])

        case let .setDeliveryAddress(isEmpty):
            return ("set_delivery_address", [
                "is_empty": isEmpty
            ])

        case let .setReceiverPhone(isEmpty):
            return ("set_receiver_phone", [
                "is_empty": isEmpty
            ])

        case let .placeOrderTap(itemsCount, totalPrice, currency, method):
            return ("place_order_tap", [
                "items_count": itemsCount,
                "value": totalPrice,
                "currency": currency,
                "method": method
            ])

        case let .orderCreated(orderId, itemsCount, totalPrice, currency, method):
            var p: [String: Any] = [
                "items_count": itemsCount,
                "value": totalPrice,
                "currency": currency,
                "method": method
            ]
            if let orderId, orderId.isEmpty == false {
                p["order_id"] = orderId
            }
            return ("order_created", p)

        case let .orderCreateFailed(reason, method):
            return ("order_create_failed", [
                "reason": reason,
                "method": method
            ])
        }
    }
}
