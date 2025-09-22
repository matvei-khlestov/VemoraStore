//
//  ProductDetailsViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import FactoryKit

final class ProductDetailsViewModel: ProductDetailsViewModelProtocol {
    
    private let product: Product
    private let favoritesService: FavoritesServiceProtocol
    private let cartService: CartServiceProtocol
    
    // MARK: - Init
    init(
        product: Product,
        favoritesService: FavoritesServiceProtocol = Container.shared.favoritesService(),
        cartService: CartServiceProtocol = Container.shared.cartService()
    ) {
        self.product = product
        self.favoritesService = favoritesService
        self.cartService = cartService
    }
    
    // MARK: - Outputs (для UI)
    var title: String { product.name }
    var description: String { product.description }
    
    /// Готовая строка цены
    var priceText: String {
        // Если понадобится более красивое форматирование:
        // let f = NumberFormatter()
        // f.numberStyle = .currency
        // f.locale = Locale(identifier: "ru_RU")
        // return f.string(from: product.price as NSNumber) ?? "\(product.price) ₽"
        return "\(product.price) ₽"
    }
    
    /// Картинка товара (для контроллера, если подключишь загрузку изображений)
    var imageURL: URL? { product.image }
    
    /// Текущее состояние избранного
    var isFavorite: Bool { favoritesService.isFavorite(product.id) }
    
    // MARK: - Actions
    /// Переключить избранное
    func toggleFavorite() {
        favoritesService.toggle(productId: product.id)
    }
    
    /// Добавить в корзину (кнопка «Добавить в корзину»)
    func addToCart() {
        cartService.add(product: product, quantity: 1)
    }
    
    /// Добавить в корзину сразу с количеством (используется, если вызовешь из контроллера с qty)
    /// Зависит от реализации CartService. Пока — добавляем товар qty раз.
    func addToCart(quantity: Int) {
        guard quantity > 0 else { return }
        for _ in 0..<quantity {
            cartService.add(product: product, quantity: 1)
        }
    }
    
    /// Обновить количество товара в корзине до конкретного значения.
    /// Оставлено как хук под будущую реализацию CartService (setQuantity/remove).
    /// Сейчас — заглушка, чтобы контроллер мог вызывать метод без ошибок компиляции.
    func updateQuantity(_ quantity: Int) {
        // TODO: когда появится API в CartService:
        // if quantity <= 0 { cartService.remove(productId: product.id) }
        // else { cartService.set(productId: product.id, quantity: quantity) }
    }
}
