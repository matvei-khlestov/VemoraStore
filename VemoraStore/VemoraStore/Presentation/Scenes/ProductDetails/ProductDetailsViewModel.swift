//
//  ProductDetailsViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

final class ProductDetailsViewModel: ProductDetailsViewModelProtocol {
    
    private let productId: String
    private let favoritesService: FavoritesServiceProtocol
    private let cartRepository: CartRepository
    private let catalogRepository: CatalogRepository
    private var cancellables = Set<AnyCancellable>()
    
    @Published private var product: Product?
    @Published private var isInCart: Bool = false   // состояние «в корзине»
    
    // MARK: - Init
    init(
        productId: String,
        favoritesService: FavoritesServiceProtocol,
        cartRepository: CartRepository,
        catalogRepository: CatalogRepository
    ) {
        self.productId = productId
        self.favoritesService = favoritesService
        self.cartRepository = cartRepository
        self.catalogRepository = catalogRepository
        
        // Продукт
        catalogRepository.observeProduct(id: productId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] product in
                self?.product = product
            }
            .store(in: &cancellables)
        
        // Корзина: наблюдаем, находится ли этот товар в корзине
        cartRepository.observeItems()
            .map { items in items.contains(where: { $0.productId == productId && $0.quantity > 0 }) }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$isInCart)
    }
    
    // MARK: - Outputs (для UI)
    var title: String { product?.name ?? "Загрузка..." }
    var description: String { product?.description ?? "" }
    
    var priceText: String {
        guard let price = product?.price else { return "" }
        return "\(price) ₽"
    }
    
    var imageURL: String? { product?.imageURL }
    
    var isFavorite: Bool { favoritesService.isFavorite(productId) }
    
    var productPublisher: AnyPublisher<Product?, Never> {
        $product.eraseToAnyPublisher()
    }
    
    var isInCartPublisher: AnyPublisher<Bool, Never> {
        $isInCart.eraseToAnyPublisher()
    }
    
    var currentIsInCart: Bool { isInCart }
    
    // MARK: - Actions
    func toggleFavorite() {
        favoritesService.toggle(productId: productId)
    }
    
    func addToCart() {
        Task { try? await cartRepository.add(productId: productId, by: 1) }
    }
    
    func addToCart(quantity: Int) {
        guard quantity > 0 else { return }
        Task { try? await cartRepository.add(productId: productId, by: quantity) }
    }
    
    func updateQuantity(_ quantity: Int) {
        Task { try? await cartRepository.setQuantity(productId: productId, quantity: quantity) }
    }
    
    func removeFromCart() {
        Task { try? await cartRepository.remove(productId: productId) }
    }
}
