//
//  CategoryProductsViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 07.10.2025.
//

import Foundation
import Combine

final class CategoryProductsViewModel: CategoryProductsViewModelProtocol {

    // MARK: - Inputs
    
    @Published var query: String = ""

    // MARK: - Outputs
    
    @Published private(set) var products: [Product] = []
    var productsPublisher: AnyPublisher<[Product], Never> {
        $products.eraseToAnyPublisher()
    }

    var inCartIdsPublisher: AnyPublisher<Set<String>, Never> {
        $inCartIds.eraseToAnyPublisher()
    }

    // MARK: - Deps
    
    private let repo: CatalogRepository
    private let cart: CartRepository
    private let categoryId: String

    // MARK: - State
    
    private var bag = Set<AnyCancellable>()
    private var realtimeStarted = false
    @Published private var inCartIds = Set<String>()

    // MARK: - Init
    
    init(
        repository: CatalogRepository,
        cartRepository: CartRepository,
        categoryId: String
    ) {
        self.repo = repository
        self.cart = cartRepository
        self.categoryId = categoryId
        bind()
    }

    // MARK: - Public
    
    func reload() {
        Task { [weak self] in
            guard let self else { return }
            do { try await repo.refreshAll() }
            catch {
                print("❌ CategoryProductsViewModel.refreshAll error:", error)
            }
        }
        if !realtimeStarted {
            repo.startRealtimeSync()
            realtimeStarted = true
        }
    }

    func addToCart(productId: String) {
        Task { try? await cart.add(productId: productId, by: 1) }
    }

    func removeFromCart(productId: String) {
        Task { try? await cart.remove(productId: productId) }
    }
}

// MARK: - Bindings

private extension CategoryProductsViewModel {
    func bind() {
        // продукты категории с поиском
        $query
            .removeDuplicates()
            .debounce(for: .milliseconds(250), scheduler: DispatchQueue.main)
            .map { [repo, categoryId] q -> AnyPublisher<[Product], Never> in
                let trimmed = q.trimmingCharacters(in: .whitespacesAndNewlines)
                return repo.observeProducts(
                    query: trimmed.isEmpty ? nil : trimmed,
                    categoryId: categoryId
                )
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .assign(to: &$products)

        // корзина -> множество id в корзине
        cart.observeItems()
            .map { Set($0.map(\.productId)) }
            .receive(on: DispatchQueue.main)
            .assign(to: &$inCartIds)
    }
}

