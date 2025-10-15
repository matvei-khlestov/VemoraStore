//
//  FavoritesViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

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
    
    // MARK: - State
    @Published private(set) var favoriteItems: [FavoriteItem] = []
    @Published private(set) var inCartIds: Set<String> = []
    
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    init(
        favoritesRepository: FavoritesRepository,
        cartRepository: CartRepository,
        priceFormatter: PriceFormattingProtocol
    ) {
        self.favorites = favoritesRepository
        self.cart = cartRepository
        self.priceFormatter = priceFormatter
        bind()
    }
    
    private func bind() {
        // 1) Избранное → прямой список FavoriteItem
        favorites.observeItems()
            .receive(on: DispatchQueue.main)
            .assign(to: &$favoriteItems)
        
        // 2) Корзина → множество id для кнопок «В корзину»
        cart.observeItems()
            .map { Set($0.map(\.productId)) }
            .receive(on: DispatchQueue.main)
            .assign(to: &$inCartIds)
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
        Task { try? await favorites.toggle(productId: id) }
    }
    
    func toggleCart(for id: String) {
        if inCartIds.contains(id) {
            Task { try? await cart.remove(productId: id) }
        } else {
            Task { try? await cart.add(productId: id, by: 1) }
        }
    }
    
    func removeItem(with productId: String) {
        Task { try? await favorites.toggle(productId: productId) }
        if let idx = favoriteItems.firstIndex(where: { $0.productId == productId }) {
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
}
