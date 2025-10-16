//
//  FavoritesRepositoryMock.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import Foundation
import Combine
@testable import VemoraStore

final class FavoritesRepositoryMock: FavoritesRepository {

    let itemsSubject = CurrentValueSubject<[FavoriteItem], Never>([])

    private(set) var refreshCalls = 0
    private(set) var addCalls: [String] = []
    private(set) var removeCalls: [String] = []
    private(set) var toggleCalls: [String] = []
    private(set) var clearCalls = 0

    func observeItems() -> AnyPublisher<[FavoriteItem], Never> {
        itemsSubject.eraseToAnyPublisher()
    }

    func observeIds() -> AnyPublisher<Set<String>, Never> {
        itemsSubject.map { Set($0.map(\.productId)) }.eraseToAnyPublisher()
    }

    func refresh(uid: String) async throws { refreshCalls += 1 }
    func add(productId: String) async throws { addCalls.append(productId) }
    func remove(productId: String) async throws { removeCalls.append(productId) }
    func toggle(productId: String) async throws { toggleCalls.append(productId) }
    func clear() async throws { clearCalls += 1 }
}
