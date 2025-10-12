//
//  ProductDetailsViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 22.09.2025.
//

import Foundation
import Combine

protocol ProductDetailsViewModelProtocol: AnyObject {
    
    // MARK: - Outputs (для UI)
    
    var title: String { get }
    var description: String { get }
    var priceText: String { get }
    var imageURL: String? { get }
    var isFavorite: Bool { get }
    var currentIsInCart: Bool { get }
    var productPublisher: AnyPublisher<Product?, Never> { get }
    var isInCartPublisher: AnyPublisher<Bool, Never> { get }
    var isFavoritePublisher: AnyPublisher<Bool, Never> { get }
    
    // MARK: - Actions
    
    func toggleFavorite()
    func addToFavorites()
    func removeFromFavorites()
    
    func addToCart()
    func addToCart(quantity: Int)
    func updateQuantity(_ quantity: Int)
    func removeFromCart()
}
