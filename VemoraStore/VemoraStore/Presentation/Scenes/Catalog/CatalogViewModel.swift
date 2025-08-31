//
//  CatalogViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import FactoryKit

final class CatalogViewModel {
    
    private let productService: ProductServiceProtocol
    
    init(productService: ProductServiceProtocol = Container.shared.productService()) {
        self.productService = productService
    }
}
