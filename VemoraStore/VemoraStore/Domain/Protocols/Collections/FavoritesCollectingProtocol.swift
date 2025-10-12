//
//  FavoritesCollectingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.10.2025.
//

import Combine

protocol FavoritesCollectingProtocol: AnyObject {
    func fetch(uid: String) async throws -> [FavoriteDTO]
    func add(uid: String, dto: FavoriteDTO) async throws
    func remove(uid: String, productId: String) async throws
    func clear(uid: String) async throws
    func listen(uid: String) -> AnyPublisher<[FavoriteDTO], Never>
}
