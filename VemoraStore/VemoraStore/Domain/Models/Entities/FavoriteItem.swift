//
//  FavoriteItem.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.10.2025.
//

import Foundation

struct FavoriteItem: Equatable, Hashable {
    let userId: String
    let productId: String
    var brandName: String
    var title: String
    var price: Double
    var imageURL: String?
    var updatedAt: Date
}
