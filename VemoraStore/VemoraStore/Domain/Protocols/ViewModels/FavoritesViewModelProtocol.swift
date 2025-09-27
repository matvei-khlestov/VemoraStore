//
//  FavoritesViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 22.09.2025.
//

import Combine
import Foundation

protocol FavoritesViewModelProtocol: AnyObject {
    // Outputs
    var favoriteProductsPublisher: AnyPublisher<[ProductTest], Never> { get }
    var inCartIdsPublisher: AnyPublisher<Set<String>, Never> { get }
    
    // Snapshot-доступ для dataSource
    var count: Int { get }
    func product(at indexPath: IndexPath) -> ProductTest
    
    // Actions
    func isFavorite(_ id: String) -> Bool
    func toggleFavorite(id: String)
    
    func isInCart(_ id: String) -> Bool
    func toggleCart(for id: String)
    
    func removeItem(at index: Int)
    
    // Временный мок (можно убрать, когда будут реальные сервисы)
    func loadMocks()
}
