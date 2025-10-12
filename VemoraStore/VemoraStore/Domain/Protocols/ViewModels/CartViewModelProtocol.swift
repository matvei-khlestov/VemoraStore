//
//  CartViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 22.09.2025.
//

import Foundation
import Combine

protocol CartViewModelProtocol {
    // Publishers
    var cartItemsPublisher: AnyPublisher<[CartItem], Never> { get }
    
    // State
    var cartItems: [CartItem] { get }
    var count: Int { get }
    var totalItems: Int { get }
    var totalPrice: Double { get }
    
    // Access
    func item(at indexPath: IndexPath) -> CartItem
    
    // Quantity
    func setQuantity(for productId: String, quantity: Int)
    func increaseQuantity(for productId: String)
    func decreaseQuantity(for productId: String)
    
    // Remove
    func removeItem(at index: Int)
    func removeItem(with productId: String)
    
    // Clear all
    func clearCart()
}
