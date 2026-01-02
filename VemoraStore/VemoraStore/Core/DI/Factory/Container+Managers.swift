//
//  Container+Managers.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 13.10.2025.
//

import Foundation
import FactoryKit

/// Расширение `Container+Managers` — регистрация менеджеров и вспомогательных сервисов в DI-контейнере.
///
/// Назначение:
/// - Определяет фабрики (`FactoryKit`) для менеджеров верхнего уровня, в частности `SessionManager`;
/// - Обеспечивает централизованное создание и хранение long-living сервисов (singletons);
/// - Включает hook-метод `resetUserScopedSingletons()` для очистки зависимостей при смене пользователя.
///
/// Состав:
/// - `sessionManager`: фабрика для `SessionManaging` (singleton), отвечающего за:
///   - реакцию на смену `auth.currentUserId`;
///   - очистку user-scoped локальных данных (`CartLocalStore`, `FavoritesLocalStore`, `ProfileLocalStore`, `OrdersLocalStore`);
///   - регистрацию уведомлений и подписку на корзину;
///   - взаимодействие с checkout-хранилищем и контейнером DI.
/// - `resetUserScopedSingletons()`: точка расширения для ручного сброса зависимостей при logout/login.
///
/// Особенности:
/// - Используется `FactoryKit` для ленивого создания зависимостей;
/// - `sessionManager` объявлен как `.singleton`, чтобы сохранять жизненный цикл в рамках приложения;
/// - Пока метод `resetUserScopedSingletons()` является no-op, но поддерживает расширение при появлении user-scoped VM/репозиториев.
/// 
/// Расширение входит в модуль Dependency Injection (`Container+...`) и используется при запуске приложения.

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
