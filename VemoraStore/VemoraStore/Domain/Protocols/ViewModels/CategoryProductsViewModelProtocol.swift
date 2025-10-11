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

    // API
    func reload()
}
