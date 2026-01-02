//
//  CartItemTest.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.09.2025.
//

import Foundation

/// Элемент корзины
struct CartItemTest: Identifiable {
    let id: String
    let product: Product
    var quantity: Int
}
