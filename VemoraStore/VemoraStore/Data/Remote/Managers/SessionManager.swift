//
//  SessionManager.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 13.10.2025.
//

import Foundation
import Combine
import FactoryKit

/// Класс `SessionManager` — лёгкий менеджер пользовательской сессии.
///
/// Назначение:
/// - отслеживает изменения состояния авторизации (`auth.currentUserId`);
/// - выполняет очистку всех локальных хранилищ, связанных с предыдущим пользователем;
/// - сбрасывает user-scoped зависимости в контейнере `FactoryKit.Container`;
/// - сохраняет снимок текущей корзины (`cartItemsSnapshot`) для быстрого доступа.
///
/// Сценарии использования:
/// - вызывается при старте приложения для синхронизации локальных данных с текущей сессией;
/// - реагирует на смену пользователя (login/logout) через Combine-подписку `auth.isAuthorizedPublisher`;
/// - может использоваться вручную через `refreshNow()` для немедленного обновления состояния.
///
/// Состав зависимостей:
/// - `AuthServiceProtocol`: источник статуса авторизации;
/// - `LocalNotifyingProtocol`: управление локальными уведомлениями;
/// - `CartLocalStore`, `FavoritesLocalStore`, `ProfileLocalStore`, `OrdersLocalStore`: локальные CoreData-хранилища;
/// - `cartRepositoryProvider`: фабрика репозиториев корзины для конкретного пользователя;
/// - `Container`: DI-контейнер для сброса user-scoped зависимостей;
/// - `CheckoutStoringProtocol`: локальное хранилище для оформления заказа.
///
/// Особенности реализации:
/// - использует `Combine` для реактивного слежения за изменением UID;
/// - кеширует последний UID (`lastUID`), чтобы избежать лишней очистки при повторных вызовах;
/// - при выходе очищает все user-scoped данные и уведомления;
/// - при входе загружает локальный снимок корзины и подписывается на её обновления через репозиторий.

final class SessionManager: SessionManaging {
    
    // MARK: - Deps
    
    private let auth: AuthServiceProtocol
    private let notifier: LocalNotifyingProtocol
    private let cartRepositoryProvider: (String) -> CartRepository
    private var cartRepoCancellable: AnyCancellable?
    private let container: Container
    private let checkoutStorage: CheckoutStoringProtocol
    
    private let cartLocal: CartLocalStore
    private let favoritesLocal: FavoritesLocalStore
    private let profileLocal: ProfileLocalStore
    private let ordersLocal: OrdersLocalStore
    
    // MARK: - State
    
    private var bag = Set<AnyCancellable>()
    private var lastUID: String?
    private(set) var cartItemsSnapshot: [CartItem] = []
    
    // MARK: - Init
    
    init(
        auth: AuthServiceProtocol,
        notifier: LocalNotifyingProtocol,
        container: Container,
        cartLocal: CartLocalStore,
        favoritesLocal: FavoritesLocalStore,
        profileLocal: ProfileLocalStore,
        ordersLocal: OrdersLocalStore,
        cartRepositoryProvider: @escaping (String) -> CartRepository,
        checkoutStorage: CheckoutStoringProtocol
    ) {
        self.auth = auth
        self.notifier = notifier
        self.container = container
        self.cartLocal = cartLocal
        self.favoritesLocal = favoritesLocal
        self.profileLocal = profileLocal
        self.ordersLocal = ordersLocal
        self.cartRepositoryProvider = cartRepositoryProvider
        self.checkoutStorage = checkoutStorage
    }
    
    // MARK: - Public
    
    func start() {
        notifier.requestAuthorization(options: [.alert, .badge, .sound], completion: nil)
        notifier.registerCategories([
            LocalNotificationFactory.favoritesCategory(),
            LocalNotificationFactory.cartCategory(),
            LocalNotificationFactory.checkoutCategory()
        ])
        auth.isAuthorizedPublisher
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.handleAuthStateChanged()
            }
            .store(in: &bag)
        
        handleAuthStateChanged()
    }
    
    func refreshNow() {
        handleAuthStateChanged()
    }
}

// MARK: - Private

private extension SessionManager {
    private func handleAuthStateChanged() {
        let current = auth.currentUserId ?? ""
        guard current != lastUID else { return }
        
        let prev = lastUID
        lastUID = current
        
        if let prev, !prev.isEmpty {
            clearLocalUserScopedData(for: prev)
        }
        container.resetUserScopedSingletons()
        
        cartRepoCancellable?.cancel()
        
        if !current.isEmpty {
            if let preload = cartLocal.snapshot(userId: current) {
                cartItemsSnapshot = preload
            } else {
                cartItemsSnapshot = []
            }
            
            let repo = cartRepositoryProvider(current)
            cartRepoCancellable = repo.observeItems()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] items in
                    self?.cartItemsSnapshot = items
                }
        } else {
            cartItemsSnapshot = []
        }
    }
    
    func clearLocalUserScopedData(for uid: String) {
        cartLocal.clear(userId: uid)
        favoritesLocal.clear(userId: uid)
        profileLocal.clear(userId: uid)
        ordersLocal.clear(userId: uid)
        checkoutStorage.reset()
        notifier.cancelAll()
    }
}
