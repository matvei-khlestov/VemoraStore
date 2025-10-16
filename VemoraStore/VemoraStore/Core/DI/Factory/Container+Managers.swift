//
//  Container+Managers.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 13.10.2025.
//

import Foundation
import FactoryKit

extension Container {
    var sessionManager: Factory<SessionManaging> {
        self {
            SessionManager(
                auth: self.authService(),
                notifier: self.localNotificationService(),
                container: self,
                cartLocal: self.cartLocalStore(),
                favoritesLocal: self.favoritesLocalStore(),
                profileLocal: self.profileLocalStore(),
                ordersLocal: self.ordersLocalStore(),
                cartRepositoryProvider: { uid in self.cartRepository(uid) },
                checkoutStorage: self.checkoutStorage()
            )
        }.singleton
    }
    
    // MARK: - User-scoped cleanup hook
    /// Сброс потенциальных user-scoped singleton’ов при смене пользователя.
    /// Сейчас VM и репозитории создаются через ParameterFactory, поэтому — no-op.
    func resetUserScopedSingletons() {
        // 🔹 пока ничего не делаем
        // если позже появятся user-scoped singletons:
        // clearSingleton(for: \.favoritesViewModel)
        // clearSingleton(for: \.cartViewModel)
    }
}
