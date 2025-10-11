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

    // MARK: - Deps
    
    private let repo: CatalogRepository
    private let categoryId: String

    // MARK: - State
    
    private var bag = Set<AnyCancellable>()
    private var realtimeStarted = false

    // MARK: - Init
    
    init(repository: CatalogRepository, categoryId: String) {
        self.repo = repository
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
}

// MARK: - Bindings

private extension CategoryProductsViewModel {
    func bind() {
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
    }
}

