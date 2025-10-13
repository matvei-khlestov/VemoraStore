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
    private let container: Container

    // Локальные сторы, которые завязаны на userId (можно расширять списком).
    private let cartLocal: CartLocalStore
    private let favoritesLocal: FavoritesLocalStore
    private let profileLocal: ProfileLocalStore

    // MARK: - State
    
    private var bag = Set<AnyCancellable>()
    private var lastUID: String?

    // MARK: - Init
    
    init(
        auth: AuthServiceProtocol,
        container: Container,
        cartLocal: CartLocalStore,
        favoritesLocal: FavoritesLocalStore,
        profileLocal: ProfileLocalStore
    ) {
        self.auth = auth
        self.container = container
        self.cartLocal = cartLocal
        self.favoritesLocal = favoritesLocal
        self.profileLocal = profileLocal
    }

    // MARK: - Public
    
    func start() {
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
    func handleAuthStateChanged() {
        let current = auth.currentUserId
        guard current != lastUID else { return }

        let prev = lastUID
        lastUID = current

        // Если был пользователь — подчистим его локальные данные (cart/favorites/profile).
        if let prevUID = prev, !prevUID.isEmpty {
            clearLocalUserScopedData(for: prevUID)
        }

        // На смену сессии сбрасываем потенциальные user-scoped singleton'ы (пока noop).
        container.resetUserScopedSingletons()
    }

    func clearLocalUserScopedData(for uid: String) {
        cartLocal.clear(userId: uid)
        favoritesLocal.clear(userId: uid)
        profileLocal.clear(userId: uid)
    }
}
