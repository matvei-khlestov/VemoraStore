//
//  FavoritesService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

final class FavoritesService: FavoritesServiceProtocol {
    static let shared = FavoritesService()
    private init() {}

    private let subject = CurrentValueSubject<Set<String>, Never>([])
    
    var favoritesIdsPublisher: AnyPublisher<Set<String>, Never> {
        subject.eraseToAnyPublisher()
    }
    
    func toggle(productId: String) {
        var set = subject.value
        if set.contains(productId) {
            set.remove(productId)
        } else {
            set.insert(productId)
        }
        subject.send(set)
    }
    
    func isFavorite(_ productId: String) -> Bool {
        subject.value.contains(productId)
    }
}
