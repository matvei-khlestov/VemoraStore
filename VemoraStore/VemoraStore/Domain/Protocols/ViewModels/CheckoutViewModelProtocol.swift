//
//  CheckoutViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 17.09.2025.
//

import Combine

/// Контракт ViewModel для экрана оформления заказа.
///
/// Определяет публичные паблишеры состояния и интенты, связанные
/// с выбором способа доставки, вводом адреса, телефона и комментария,
/// а также подтверждением и оформлением заказа.
///
/// Используется во `CheckoutViewController` для биндинга UI и управления логикой оформления.

protocol CheckoutViewModelProtocol: AnyObject {

    // MARK: - Publishers (для bind в VC)
    
    /// Публикует текущий способ получения заказа (pickup/delivery).
    var deliveryMethodPublisher: AnyPublisher<CheckoutViewModel.DeliveryMethod, Never> { get }
    
    /// Публикует строку адреса доставки для отображения.
    var deliveryAddressStringPublisher: AnyPublisher<String?, Never> { get }
    
    /// Публикует телефон получателя в человекочитаемом формате.
    var receiverPhoneDisplayPublisher: AnyPublisher<String?, Never> { get }
    
    /// Публикует текст комментария к заказу.
    var orderCommentPublisher: AnyPublisher<String?, Never> { get }
    
    /// Публикует актуальный список товаров в корзине.
    var itemsPublisher: AnyPublisher<[CartItem], Never> { get }
    
    /// Публикует флаг готовности к оформлению заказа (валидные данные).
    var isPlaceOrderEnabled: AnyPublisher<Bool, Never> { get }

    // MARK: - State (read-only)
    
    /// Текущий способ получения заказа.
    var deliveryMethod: CheckoutViewModel.DeliveryMethod { get }
    
    /// Адрес доставки в виде строки.
    var deliveryAddressString: String? { get }
    
    /// Телефон получателя в формате E.164.
    var receiverPhoneE164: String? { get }
    
    /// Текст комментария к заказу.
    var orderCommentText: String? { get }
    
    /// Телефон получателя для отображения.
    var receiverPhoneDisplay: String? { get }
    
    /// Снимок текущих позиций корзины.
    var itemsSnapshot: [CartItem] { get }

    // MARK: - Intents
    
    /// Устанавливает способ получения заказа.
    func setDeliveryMethod(_ method: CheckoutViewModel.DeliveryMethod)
    
    /// Обновляет строку адреса доставки.
    func updateDeliveryAddress(_ fullAddress: String)
    
    /// Обновляет телефон получателя (E.164).
    func updateReceiverPhone(_ e164: String?)
    
    /// Обновляет текст комментария к заказу.
    func updateOrderComment(_ text: String?)
    
    /// Валидирует данные и создаёт заказ; может бросать ошибку.
    func placeOrder() async throws
    
    /// Возвращает отформатированную итоговую сумму по товарам.
    func formattedTotalPrice(from items: [CartItem]) -> String
    
    /// Форматирует отдельную цену.
    func formattedPrice(_ price: Double) -> String
    
    /// Очищает корзину после успешного оформления.
    func clearCart() async
}
