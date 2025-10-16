//
//  FavoritesViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine
import UserNotifications

final class FavoritesViewModel: FavoritesViewModelProtocol {
    
    // MARK: - Publishers
    
    var favoriteItemsPublisher: AnyPublisher<[FavoriteItem], Never> {
        $favoriteItems.eraseToAnyPublisher()
    }
    var inCartIdsPublisher: AnyPublisher<Set<String>, Never> {
        $inCartIds.eraseToAnyPublisher()
    }
    
    // MARK: - Deps
    
    private let favorites: FavoritesRepository
    private let cart: CartRepository
    private let priceFormatter: PriceFormattingProtocol
    private let notifier: LocalNotifyingProtocol
    
    // MARK: - State
    
    @Published private(set) var favoriteItems: [FavoriteItem] = []
    @Published private(set) var inCartIds: Set<String> = []
    
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(
        favoritesRepository: FavoritesRepository,
        cartRepository: CartRepository,
        priceFormatter: PriceFormattingProtocol,
        notifier: LocalNotifyingProtocol
    ) {
        self.favorites = favoritesRepository
        self.cart = cartRepository
        self.priceFormatter = priceFormatter
        self.notifier = notifier
        bind()
    }
    
    private func bind() {
        favorites.observeItems()
            .receive(on: DispatchQueue.main)
            .assign(to: &$favoriteItems)
        
        cart.observeItems()
            .map { Set($0.map(\.productId)) }
            .receive(on: DispatchQueue.main)
            .assign(to: &$inCartIds)
        
        Publishers.CombineLatest($favoriteItems, $inCartIds)
            .removeDuplicates { lhs, rhs in
                lhs.0.map(\.productId) == rhs.0.map(\.productId) && lhs.1 == rhs.1
            }
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .sink { [weak self] favs, inCart in
                self?.updateFavoritesReminder(favorites: favs, inCartIds: inCart)
            }
            .store(in: &bag)
    }
    
    // MARK: - Public API
    
    var count: Int { favoriteItems.count }
    
    func item(at indexPath: IndexPath) -> FavoriteItem {
        favoriteItems[indexPath.row]
    }
    
    func isInCart(_ id: String) -> Bool {
        inCartIds.contains(id)
    }
    
    func toggleFavorite(id: String) {
        Task {
            try? await favorites.toggle(productId: id)
        }
    }
    
    func toggleCart(for id: String) {
        if inCartIds.contains(id) {
            Task {
                try? await cart.remove(productId: id)
            }
        } else {
            Task {
                try? await cart.add(productId: id, by: 1)
            }
        }
    }
    
    func removeItem(with productId: String) {
        Task { try? await favorites.toggle(productId: productId) }
        if let idx = favoriteItems.firstIndex(where: {
            $0.productId == productId
        }) {
            favoriteItems.remove(at: idx)
        }
        inCartIds.remove(productId)
    }
    
    func clearFavorites() {
        Task { try? await favorites.clear() }
        favoriteItems.removeAll()            
    }
    
    func formattedPrice(_ price: Double) -> String {
        priceFormatter.format(price: price)
    }

    // MARK: - Local Notifications

    private func updateFavoritesReminder(favorites: [FavoriteItem], inCartIds: Set<String>) {
        let hasFavorites = !favorites.isEmpty
        let anyFavInCart = favorites.contains { inCartIds.contains($0.productId) }

        if hasFavorites && !anyFavInCart {
            #if DEBUG
            _ = notifier.schedule(
                after: 10,
                id: NotificationTemplate.Favorites.id,
                title: NotificationTemplate.Favorites.title,
                body: NotificationTemplate.Favorites.body,
                categoryId: NotificationTemplate.Favorites.categoryId,
                userInfo: NotificationTemplate.Favorites.userInfo,
                unique: true
            )
            #else
            let now = Date()
            let target = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now.addingTimeInterval(24*60*60)
            var comps = Calendar.current.dateComponents([.year, .month, .day], from: target)
            comps.hour = 10
            comps.minute = 0
            let date = Calendar.current.date(from: comps) ?? now.addingTimeInterval(24*60*60)

            _ = notifier.schedule(
                id: NotificationTemplate.Favorites.id,
                title: NotificationTemplate.Favorites.title,
                body: NotificationTemplate.Favorites.body,
                at: date,
                categoryId: NotificationTemplate.Favorites.categoryId,
                userInfo: NotificationTemplate.Favorites.userInfo,
                unique: true
            )
            #endif
        } else {
            notifier.cancel(ids: [NotificationTemplate.Favorites.id])
        }
    }
}
