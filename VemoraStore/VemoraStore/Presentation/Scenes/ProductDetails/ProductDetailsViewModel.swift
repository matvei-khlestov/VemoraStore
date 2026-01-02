//
//  ProductDetailsViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

/// ViewModel `ProductDetailsViewModel` для экрана карточки товара.
///
/// Основные задачи:
/// - Подписывается на `CatalogRepository` и публикует `product`;
/// - Отслеживает состояние в корзине и избранном
///   через `CartRepository` и `FavoritesRepository`;
/// - Формирует данные для UI: название, описание,
///   форматированную цену, URL изображения;
/// - Предоставляет паблишеры: `productPublisher`,
///   `isInCartPublisher`, `isFavoritePublisher`.
///
/// Действия:
/// - Тоггл/добавление/удаление из избранного;
/// - Добавление в корзину, обновление количества,
///   удаление из корзины.
///
/// Форматирование:
/// - Цена форматируется через `PriceFormattingProtocol`.
///
/// Реактивность:
/// - Обновления доставляются на главный поток;
/// - Состояния `isInCart` и `favoriteState` дедуплицируются.

final class ProductDetailsViewModel: ProductDetailsViewModelProtocol {
    
    private let productId: String
    private let favoritesRepository: FavoritesRepository
    private let cartRepository: CartRepository
    private let catalogRepository: CatalogRepository
    private let priceFormatter: PriceFormattingProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published private var product: Product?
    @Published private var isInCart: Bool = false
    @Published private var favoriteState: Bool = false
    
    // MARK: - Init
    
    init(
        productId: String,
        favoritesRepository: FavoritesRepository,
        cartRepository: CartRepository,
        catalogRepository: CatalogRepository,
        priceFormatter: PriceFormattingProtocol,
    ) {
        self.productId = productId
        self.favoritesRepository = favoritesRepository
        self.cartRepository = cartRepository
        self.catalogRepository = catalogRepository
        self.priceFormatter = priceFormatter
        
        catalogRepository.observeProduct(id: productId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] product in
                self?.product = product
            }
            .store(in: &cancellables)
        
        cartRepository.observeItems()
            .map { items in items.contains(where: {
                $0.productId == productId && $0.quantity > 0
            }) }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$isInCart)
        
        favoritesRepository.observeIds()
            .map { ids in ids.contains(productId) }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$favoriteState)
    }
    
    // MARK: - Outputs
    
    var title: String {
        product?.name ?? "Загрузка..."
    }
    var description: String {
        product?.description ?? ""
    }
    
    var priceText: String {
        guard let price = product?.price else { return "" }
        return formattedPrice(price)
    }
    
    var imageURL: String? {
        product?.imageURL
    }
    
    var isFavorite: Bool {
        favoriteState
    }
    
    var productPublisher: AnyPublisher<Product?, Never> {
        $product.eraseToAnyPublisher()
    }
    
    var isInCartPublisher: AnyPublisher<Bool, Never> {
        $isInCart.eraseToAnyPublisher()
    }
    
    var isFavoritePublisher: AnyPublisher<Bool, Never> {
        $favoriteState.eraseToAnyPublisher()
    }
    
    var currentIsInCart: Bool {
        isInCart
    }
    
    // MARK: - Favorites actions
    
    func toggleFavorite() {
        Task {
            try? await favoritesRepository.toggle(productId: productId)
        }
    }
    
    func addToFavorites() {
        Task {
            try? await favoritesRepository.add(productId: productId)
        }
    }
    
    func removeFromFavorites() {
        Task {
            try? await favoritesRepository.remove(productId: productId)
        }
    }
    
    // MARK: - Cart actions
    
    func addToCart() {
        Task {
            try? await cartRepository.add(productId: productId, by: 1)
        }
    }
    
    func addToCart(quantity: Int) {
        guard quantity > 0 else { return }
        Task {
            try? await cartRepository.add(productId: productId, by: quantity)
        }
    }
    
    func updateQuantity(_ quantity: Int) {
        Task {
            try? await cartRepository.setQuantity(productId: productId, quantity: quantity)
        }
    }
    
    func removeFromCart() {
        Task {
            try? await cartRepository.remove(productId: productId)
        }
    }
    
    // MARK: - Price
    
    private func formattedPrice(_ price: Double) -> String {
        priceFormatter.format(price: price)
    }
}
