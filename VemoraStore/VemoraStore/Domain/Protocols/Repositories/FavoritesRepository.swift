//
//  FavoritesRepository.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.10.2025.
//

import Combine

protocol FavoritesRepository: AnyObject {
    func observeItems() -> AnyPublisher<[FavoriteItem], Never>
    func observeIds() -> AnyPublisher<Set<String>, Never>

    func refresh(uid: String) async throws
    func add(productId: String) async throws
    func remove(productId: String) async throws
    func toggle(productId: String) async throws
    func clear() async throws
}
