//
//  CategoryProductsViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 07.10.2025.
//

import Combine

protocol CategoryProductsViewModelProtocol: AnyObject {
    
    // Inputs
    var query: String { get set }
    
    // Outputs
    var products: [Product] { get }
    var productsPublisher: AnyPublisher<[Product], Never> { get }
    var inCartIdsPublisher: AnyPublisher<Set<String>, Never> { get }
    var favoriteIdsPublisher: AnyPublisher<Set<String>, Never> { get }
    
    // API
    func addToCart(productId: String)
    func removeFromCart(productId: String)
    func addToFavorites(productId: String)
    func removeFromFavorites(productId: String)
    func toggleFavorite(productId: String)
    func formattedPrice(_ price: Double) -> String 
    func reload()
}
