//
//  FavoritesServiceProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

protocol FavoritesServiceProtocol {
    var favoritesIdsPublisher: AnyPublisher<Set<String>, Never> { get }
    func toggle(productId: String)
    func isFavorite(_ productId: String) -> Bool
}
