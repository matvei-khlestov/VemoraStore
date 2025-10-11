//
//  Category.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 26.09.2025.
//

import Foundation

struct Category: Codable, Equatable {
    let id: String
    let name: String
    let imageURL: String
    let brandIds: [String]
    let isActive: Bool
    let createdAt: String
    let updatedAt: String
}
