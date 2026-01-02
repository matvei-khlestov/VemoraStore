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

/// Протокол `CheckoutStoringProtocol`
///
/// Определяет интерфейс для сохранения и восстановления
/// пользовательских данных, введённых при оформлении заказа.
///
/// Основные задачи:
/// - хранение способа доставки (`pickup` или `delivery`);
/// - сохранение адреса доставки и телефона получателя;
/// - восстановление введённых данных при повторном открытии экрана оформления заказа;
/// - очистка данных после успешного завершения заказа.

protocol CheckoutStoringProtocol {
    
    /// Сохранённый способ доставки (`pickup` или `delivery`).
    var savedDeliveryMethod: SavedDeliveryMethod { get set }
    
    /// Сохранённый адрес доставки (если выбран метод `.delivery`).
    var savedDeliveryAddressString: String? { get set }
    
    /// Сохранённый телефон получателя в формате E.164 (например, `+79991234567`).
    var savedReceiverPhoneE164: String? { get set }
    
    /// Сбрасывает все сохранённые данные оформления заказа.
    func reset()
}
