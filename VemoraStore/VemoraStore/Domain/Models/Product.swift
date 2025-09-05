//
//  Product.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation

struct Product: Codable, Hashable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let image: URL
    let categoryId: String
    let brendId: String
}
