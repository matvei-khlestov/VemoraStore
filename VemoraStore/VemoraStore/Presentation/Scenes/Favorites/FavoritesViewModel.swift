//
//  FavoritesViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine
import FactoryKit

final class FavoritesViewModel {
    
    // MARK: - Services
    
    private let favoritesService: FavoritesServiceProtocol
    private let productService: ProductServiceProtocol
    
    // MARK: - State
    
    @Published private(set) var favoriteProducts: [Product] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(
        favoritesService: FavoritesServiceProtocol = Container.shared.favoritesService(),
        productService: ProductServiceProtocol = Container.shared.productService()
    ) {
        self.favoritesService = favoritesService
        self.productService = productService
        bind()
    }
    
    // MARK: - Private
    
    private func bind() {
        // Подписка на изменения списка избранных ID
        favoritesService.favoritesIdsPublisher
            .sink { [weak self] ids in
                self?.loadProducts(for: ids)
            }
            .store(in: &cancellables)
    }
    
    private func loadProducts(for ids: Set<String>) {
        guard !ids.isEmpty else {
            favoriteProducts = []
            return
        }
        productService.products()
            .replaceError(with: [])
            .map { $0.filter { ids.contains($0.id) } }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.favoriteProducts = $0 }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    func toggleFavorite(id: String) {
        favoritesService.toggle(productId: id)
    }
    
    func isFavorite(_ id: String) -> Bool {
        favoritesService.isFavorite(id)
    }
}
