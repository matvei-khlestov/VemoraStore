//
//  FavoritesViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine
import FactoryKit

final class FavoritesViewModel: FavoritesViewModelProtocol {
    
    // MARK: - Publishers (protocol conformance)
    var favoriteProductsPublisher: AnyPublisher<[Product], Never> {
        $favoriteProducts.eraseToAnyPublisher()
    }

    var inCartIdsPublisher: AnyPublisher<Set<String>, Never> {
        $inCartIds.eraseToAnyPublisher()
    }
    
    // MARK: - Services
    private let favoritesService: FavoritesServiceProtocol
    private let productService: ProductServiceProtocol
    
    // MARK: - State (Outputs for Controller)
    @Published private(set) var favoriteProducts: [Product] = []
    /// Локальная корзина для отражения состояния кнопок в UI (мок).
    @Published private(set) var inCartIds: Set<String> = []
    
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
        // Подписка на изменения списка избранных ID -> подгружаем продукты
        favoritesService.favoritesIdsPublisher
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] ids in
                self?.loadProducts(for: ids)
            }
            .store(in: &cancellables)
    }
    
    private func loadProducts(for ids: Set<String>) {
        guard !ids.isEmpty else {
            DispatchQueue.main.async { [weak self] in
                self?.favoriteProducts = []
            }
            return
        }
        
        productService.products()
            .replaceError(with: [])
            .map { products in products.filter { ids.contains($0.id) } }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.favoriteProducts = $0 }
            .store(in: &cancellables)
    }
    
    // MARK: - Public API (для контроллера)
    
    /// Кол-во элементов в таблице
    var count: Int { favoriteProducts.count }
    
    func product(at indexPath: IndexPath) -> Product { favoriteProducts[indexPath.row] }
    
    func isFavorite(_ id: String) -> Bool { favoritesService.isFavorite(id) }
    
    func toggleFavorite(id: String) {
        favoritesService.toggle(productId: id)
    }
    
    /// Тоггл состояния «в корзине» для локального UI.
    func toggleCart(for id: String) {
        if inCartIds.contains(id) {
            inCartIds.remove(id)
        } else {
            inCartIds.insert(id)
        }
    }
    
    func isInCart(_ id: String) -> Bool { inCartIds.contains(id) }
    
    /// Удаление через свайп
    func removeItem(at index: Int) {
        guard favoriteProducts.indices.contains(index) else { return }
        let removed = favoriteProducts.remove(at: index)
//        favoritesService.toggle(productId: removed.id)
        inCartIds.remove(removed.id)
    }
    
    // MARK: - Mocks
    /// Явная загрузка мок-данных (если сервисы ещё не реализованы). Можно вызвать из VC в viewDidLoad().
    func loadMocks() {
        let mocks = MockData.products
        favoriteProducts = mocks
        // по желанию можно проставить часть в корзину
        inCartIds = []
    }
}

// MARK: - MockData
private enum MockData {
    static let products: [Product] = [
        Product(
            id: "p_sofa_oslo",
            name: "Vemora Oslo Sofa 3-Seater",
            description: "Compact 3-seater sofa with soft fabric upholstery and wooden legs.",
            price: 45999,
            image: URL(string: "https://picsum.photos/seed/oslo-sofa/800/600")!,
            categoryId: "sofas",
            brendId: "vemora"
        ),
        Product(
            id: "p_table_nordic",
            name: "Nordic Oak Coffee Table",
            description: "Minimal coffee table made of solid oak with rounded corners.",
            price: 12999,
            image: URL(string: "https://picsum.photos/seed/nordic-table/800/600")!,
            categoryId: "coffee_tables",
            brendId: "vemora"
        ),
        Product(
            id: "p_chair_luna",
            name: "Luna Accent Chair",
            description: "Ergonomic accent chair with textured upholstery and metal frame.",
            price: 9999,
            image: URL(string: "https://picsum.photos/seed/luna-chair/800/600")!,
            categoryId: "chairs",
            brendId: "vemora"
        ),
    ]
}
