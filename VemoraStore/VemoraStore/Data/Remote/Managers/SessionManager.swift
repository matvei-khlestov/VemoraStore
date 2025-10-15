//
//  SessionManager.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 13.10.2025.
//

import Foundation
import Combine
import FactoryKit

/// Лёгкий «сторож» сессии:
/// - слушает смену auth.currentUserId
/// - при смене uid чистит локальные user-scoped сторы
/// - даёт хук для сброса потенциальных user-scoped singleton'ов в контейнере
final class SessionManager: SessionManaging {
    
    // MARK: - Deps
    
    private let auth: AuthServiceProtocol
    private let notifier: LocalNotifyingProtocol
    private let cartRepositoryProvider: (String) -> CartRepository
    private var cartRepoCancellable: AnyCancellable?
    private let container: Container
    private let checkoutStorage: CheckoutStoringProtocol
    
    // Локальные сторы, которые завязаны на userId (можно расширять списком).
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
        // 1) Разрешения и категории — один раз при старте
        notifier.requestAuthorization(options: [.alert, .badge, .sound], completion: nil)
        notifier.registerCategories([
            LocalNotificationFactory.favoritesCategory(),
            LocalNotificationFactory.cartCategory(),
            LocalNotificationFactory.checkoutCategory()
        ])
        // Следим за авторизацией; UID берём из auth.currentUserId.
        auth.isAuthorizedPublisher
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.handleAuthStateChanged()
            }
            .store(in: &bag)
        
        // Подстрахуемся и дернём сразу.
        handleAuthStateChanged()
    }
    
    // Можно звать явно при logout/login, если хочется мгновенно применить.
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
        
        // отменим старую подписку
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
