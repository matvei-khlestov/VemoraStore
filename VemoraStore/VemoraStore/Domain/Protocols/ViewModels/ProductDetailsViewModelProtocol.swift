//
//  ProductDetailsViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 22.09.2025.
//

import Foundation

protocol ProductDetailsViewModelProtocol: AnyObject {
    // MARK: - Outputs (для UI)
    var title: String { get }
    var description: String { get }
    var priceText: String { get }
    var imageURL: String? { get }
    var isFavorite: Bool { get }
    
    // MARK: - Actions
    func toggleFavorite()
    func addToCart()
    func addToCart(quantity: Int)
    func updateQuantity(_ quantity: Int)
}
