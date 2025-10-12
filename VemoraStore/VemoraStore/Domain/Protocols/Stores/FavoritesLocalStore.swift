//
//  FavoritesLocalStore.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.10.2025.
//

import Combine
import CoreData

protocol FavoritesLocalStore: AnyObject {
    func observeItems(userId: String) -> AnyPublisher<[FavoriteItem], Never>
    func replaceAll(userId: String, with dtos: [FavoriteDTO])
    func upsert(userId: String, dto: FavoriteDTO)
    func remove(userId: String, productId: String)
    func clear(userId: String)
}

