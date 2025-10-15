//
//  CheckoutStoringProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Foundation

/// Способ доставки, сохраняемый между сессиями Checkout.
enum SavedDeliveryMethod: String {
    case pickup
    case delivery
}

/// Протокол для хранения данных, связанных с оформлением заказа.
/// Используется для восстановления последних введённых пользователем данных.
protocol CheckoutStoringProtocol {
    
    /// Сохранённый способ доставки (по умолчанию `.pickup`).
    var savedDeliveryMethod: SavedDeliveryMethod { get set }

    /// Сохранённый адрес доставки (если выбран метод `.delivery`).
    var savedDeliveryAddressString: String? { get set }

    /// Сохранённый телефон получателя в формате E.164 (например, +79991234567).
    var savedReceiverPhoneE164: String? { get set }

    /// Сбрасывает все сохранённые данные оформления заказа.
    func reset()
}
