//
//  ImportOutcome.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 26.09.2025.
//

import Foundation

struct ImportOutcome: Sendable {
    let brands: Int
    let categories: Int
    let products: Int
    let brandsDeleted: Int
    let categoriesDeleted: Int
    let productsDeleted: Int
}
extension ImportOutcome {
    func updating(
        brands: Int? = nil,
        categories: Int? = nil,
        products: Int? = nil,
        brandsDeleted: Int? = nil,
        categoriesDeleted: Int? = nil,
        productsDeleted: Int? = nil
    ) -> ImportOutcome {
        ImportOutcome(
            brands: brands ?? self.brands,
            categories: categories ?? self.categories,
            products: products ?? self.products,
            brandsDeleted: brandsDeleted ?? self.brandsDeleted,
            categoriesDeleted: categoriesDeleted ?? self.categoriesDeleted,
            productsDeleted: productsDeleted ?? self.productsDeleted
        )
    }
}
