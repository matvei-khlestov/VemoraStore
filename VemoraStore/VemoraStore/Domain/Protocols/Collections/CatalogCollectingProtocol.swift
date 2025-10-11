//
//  CatalogCollectingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import Combine

protocol CatalogCollectingProtocol: AnyObject {
    // one shot
    func fetchProducts() async throws -> [ProductDTO]
    func fetchCategories() async throws -> [CategoryDTO]
    func fetchBrands() async throws -> [BrandDTO]
    
    // realtime
    func listenProducts() -> AnyPublisher<[ProductDTO], Never>
    func listenCategories() -> AnyPublisher<[CategoryDTO], Never>
    func listenBrands() -> AnyPublisher<[BrandDTO], Never>
}
