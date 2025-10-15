//
//  FavoritesViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 22.09.2025.
//

import Combine
import Foundation

protocol FavoritesViewModelProtocol {
    // Outputs
    var favoriteItemsPublisher: AnyPublisher<[FavoriteItem], Never> { get }
    var inCartIdsPublisher: AnyPublisher<Set<String>, Never> { get }
    
    // Queries
    var count: Int { get }
    func item(at indexPath: IndexPath) -> FavoriteItem
    func isInCart(_ productId: String) -> Bool
    
    // Commands
    func toggleCart(for productId: String)
    func removeItem(with productId: String)
    func clearFavorites()
    func formattedPrice(_ price: Double) -> String
}
