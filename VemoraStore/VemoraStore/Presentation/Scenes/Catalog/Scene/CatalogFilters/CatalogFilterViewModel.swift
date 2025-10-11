//
//  CatalogFilterViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 07.10.2025.
//

import Foundation
import Combine

final class CatalogFilterViewModel: CatalogFilterViewModelProtocol {
    
    // MARK: - Deps
    
    private let repo: CatalogRepository
    
    // MARK: - Storage (списки в UI)
    
    @Published private var categoriesStorage: [Category] = []
    @Published private var brandsStorage: [Brand] = []
    
    // MARK: - Выбор пользователя
    
    private var selectedCategoryIds = Set<String>()
    private var selectedBrandIds = Set<String>()
    private var minPrice: Decimal?
    private var maxPrice: Decimal?
    
    // MARK: - Publishers (state + count)
    
    private let _state = CurrentValueSubject<FilterState, Never>(.init())
    
    var statePublisher: AnyPublisher<FilterState, Never> {
        _state.eraseToAnyPublisher()
    }
    
    private let _foundCount = CurrentValueSubject<Int, Never>(0)
    
    var foundCountPublisher: AnyPublisher<Int, Never> {
        _foundCount.eraseToAnyPublisher()
    }
    
    var currentFoundCount: Int {
        _foundCount.value
    }
    
    // MARK: - Other
    
    private var bag = Set<AnyCancellable>()
    private var productsCancellable: AnyCancellable?
    
    // MARK: - Init
    
    init(repository: CatalogRepository) {
        self.repo = repository
        
        repo.observeCategories()
            .map {
                $0.sorted {
                    $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$categoriesStorage)
        
        repo.observeBrands()
            .map {
                $0.sorted {
                    $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$brandsStorage)
        
        emitStateAndRefetch()
    }
    
    // MARK: - Outputs
    
    var categories: AnyPublisher<[Category], Never> {
        $categoriesStorage.removeDuplicates().eraseToAnyPublisher()
    }
    
    var brands: AnyPublisher<[Brand], Never> {
        $brandsStorage.removeDuplicates().eraseToAnyPublisher()
    }
    
    var currentState: FilterState {
        _state.value
    }
    
    // MARK: - Actions
    
    func toggleCategory(id: String) {
        if selectedCategoryIds.contains(id) {
            selectedCategoryIds.remove(id)
        } else {
            selectedCategoryIds.insert(id)
        }
        emitStateAndRefetch()
    }
    
    func toggleBrand(id: String) {
        if selectedBrandIds.contains(id) {
            selectedBrandIds.remove(id)
        } else {
            selectedBrandIds.insert(id)
        }
        emitStateAndRefetch()
    }
    
    func setMinPrice(_ text: String?) {
        minPrice = text.flatMap {
            Decimal(string: $0.replacingOccurrences(of: ",", with: "."))
        }
        emitStateAndRefetch()
    }
    
    func setMaxPrice(_ text: String?) {
        maxPrice = text.flatMap {
            Decimal(string: $0.replacingOccurrences(of: ",", with: "."))
        }
        emitStateAndRefetch()
    }
    
    func reset() {
        selectedCategoryIds.removeAll()
        selectedBrandIds.removeAll()
        minPrice = nil
        maxPrice = nil
        emitStateAndRefetch()
    }
    
    // MARK: - Helpers
    
    private func emitStateAndRefetch() {
        let state = FilterState(
            selectedCategoryIds:
                selectedCategoryIds,
            selectedBrandIds:
                selectedBrandIds,
            minPrice:
                minPrice,
            maxPrice:
                maxPrice
        )
        _state.send(state)
        
        let isEmptyFilter = selectedCategoryIds.isEmpty
        && selectedBrandIds.isEmpty
        && minPrice == nil
        && maxPrice == nil
        
        if isEmptyFilter {
            productsCancellable?.cancel()
            _foundCount.send(0)
            return
        }
        
        productsCancellable?.cancel()
        productsCancellable = repo.observeProducts(
            query: nil,
            categoryIds:
                selectedCategoryIds.isEmpty ? nil : selectedCategoryIds,
            brandIds:
                selectedBrandIds.isEmpty ? nil : selectedBrandIds,
            minPrice:
                minPrice,
            maxPrice:
                maxPrice
        )
        .map(\.count)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] count in
            self?._foundCount.send(count)
        }
    }
}
