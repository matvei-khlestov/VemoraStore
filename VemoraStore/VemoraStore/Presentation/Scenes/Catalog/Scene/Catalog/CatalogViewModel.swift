//
//  CatalogViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

final class CatalogViewModel: CatalogViewModelProtocol {
    
    // MARK: - Inputs
    
    @Published var query: String = ""
    
    // MARK: - Outputs
    
    @Published private(set) var categories: [Category] = []
    @Published private(set) var products: [Product] = []
    @Published private(set) var activeFiltersCount: Int = 0
    
    var categoriesPublisher: AnyPublisher<[Category], Never> {
        $categories.eraseToAnyPublisher()
    }
    
    var productsPublisher: AnyPublisher<[Product], Never> {
        $products.eraseToAnyPublisher()
    }
    
    var activeFiltersCountPublisher: AnyPublisher<Int, Never> {
        $activeFiltersCount.eraseToAnyPublisher()
    }
    
    var inCartIdsPublisher: AnyPublisher<Set<String>, Never> {
        $inCartIds.eraseToAnyPublisher()
    }
    
    var favoriteIdsPublisher: AnyPublisher<Set<String>, Never> {
        $favoriteIds.eraseToAnyPublisher()
    }
    
    // MARK: - Deps
    
    private let repo: CatalogRepository
    private let cart: CartRepository
    private let favorites: FavoritesRepository
    
    // MARK: - State
    
    private var bag = Set<AnyCancellable>()
    private var realtimeStarted = false
    private var countsByCategory: [String: Int] = [:]
    
    private var filterState = FilterState()
    
    var currentState: FilterState { filterState }
    
    private var productsCancellable: AnyCancellable?
    @Published private var inCartIds = Set<String>()
    @Published private var favoriteIds = Set<String>()
    
    // MARK: - Init
    
    init(
        repository: CatalogRepository,
        cartRepository: CartRepository,
        favoritesRepository: FavoritesRepository
    ) {
        self.repo = repository
        self.cart = cartRepository
        self.favorites = favoritesRepository
        bind()
        refreshProducts()
    }
    
    // MARK: - Public
    
    func reload() {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await repo.refreshAll()
            } catch {
                print("❌ CatalogViewModel.refreshAll error:", error)
            }
        }
        if !realtimeStarted {
            repo.startRealtimeSync()
            realtimeStarted = true
        }
    }
    
    func applyFilters(_ state: FilterState) {
        filterState = state
        recalcActiveFiltersCount()
        refreshProducts()
    }
    
    func productCount(in categoryId: String) -> Int {
        countsByCategory[categoryId] ?? 0
    }
    
    func addToCart(productId: String) {
        Task { try? await cart.add(productId: productId, by: 1) }
    }
    
    func removeFromCart(productId: String) {
        Task { try? await cart.remove(productId: productId) }
    }
    
    func addToFavorites(productId: String) {
        Task { try? await favorites.add(productId: productId) }
    }

    func removeFromFavorites(productId: String) {
        Task { try? await favorites.remove(productId: productId) }
    }

    func toggleFavorite(productId: String) {
        Task { try? await favorites.toggle(productId: productId) }
    }
}

// MARK: - Bindings + helpers

private extension CatalogViewModel {
    func bind() {
        repo.observeCategories()
            .receive(on: DispatchQueue.main)
            .assign(to: &$categories)
        
        $query
            .removeDuplicates()
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshProducts()
            }
            .store(in: &bag)
        
        cart.observeItems()
            .map { Set($0.map(\.productId)) }
            .receive(on: DispatchQueue.main)
            .assign(to: &$inCartIds)
        
        favorites.observeItems()
            .map { Set($0.map(\.productId)) }
            .receive(on: DispatchQueue.main)
            .assign(to: &$favoriteIds)
    }
    
    func refreshProducts() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let q: String? = trimmed.isEmpty ? nil : trimmed
        
        let cats = filterState.selectedCategoryIds.isEmpty ? nil
        : Set(filterState.selectedCategoryIds)
        let brands = filterState.selectedBrandIds.isEmpty ? nil
        : Set(filterState.selectedBrandIds)
        
        productsCancellable?.cancel()
        productsCancellable = repo.observeProducts(
            query: q,
            categoryIds: cats,
            brandIds: brands,
            minPrice: filterState.minPrice,
            maxPrice: filterState.maxPrice
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] items in
            self?.products = items
            self?.rebuildCounts(from: items)
        }
    }
    
    func rebuildCounts(from items: [Product]) {
        var dict: [String: Int] = [:]
        for p in items { dict[p.categoryId, default: 0] += 1 }
        countsByCategory = dict
    }
    
    func recalcActiveFiltersCount() {
        activeFiltersCount =
        filterState.selectedCategoryIds.count +
        filterState.selectedBrandIds.count +
        (filterState.minPrice == nil ? 0 : 1) +
        (filterState.maxPrice == nil ? 0 : 1)
    }
}
