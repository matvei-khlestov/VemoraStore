//
//  Product.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 26.09.2025.
//

import Foundation

struct Product: Codable {
    let id: String
    let name: String
    let description: String
    let nameLower: String
    let categoryId: String
    let brandId: String
    let price: Double
    let imageURL: String
    let isActive: Bool
    let createdAt: String
    let updatedAt: String
    let keywords: [String]
}
