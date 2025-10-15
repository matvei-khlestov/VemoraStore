//
//  SessionManaging.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 13.10.2025.
//

import Foundation

/// Протокол для менеджера пользовательской сессии.
protocol SessionManaging {
    /// Запускает наблюдение за состоянием авторизации.
    func start()
    
    /// Форсирует немедленную проверку состояния сессии.
    func refreshNow()
    
    /// Текущий снимок корзины (для одноразовой передачи на экран оформления заказа).
    var cartItemsSnapshot: [CartItem] { get }
}
