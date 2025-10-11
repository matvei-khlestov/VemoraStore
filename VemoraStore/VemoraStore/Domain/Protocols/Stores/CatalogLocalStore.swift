//
//  CatalogLocalStore.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import Combine
import Foundation
import CoreData

protocol CatalogLocalStore: AnyObject {
    
    var viewContext: NSManagedObjectContext { get }
    
    // MARK: - Observe (reactive, Core Data -> Domain)
    
    func observeProducts(
            query: String?,
            categoryIds: Set<String>?,
            brandIds: Set<String>?,
            minPrice: Decimal?,
            maxPrice: Decimal?
        ) -> AnyPublisher<[Product], Never>
    
    func observeProducts(query: String?, categoryId: String?) -> AnyPublisher<[Product], Never>
    func observeCategories() -> AnyPublisher<[Category], Never>
    func observeBrands() -> AnyPublisher<[Brand], Never>
    
    // MARK: - Upsert (bulk, DTO -> Core Data)
    
    func upsertProducts(_ dtos: [ProductDTO])
    func upsertCategories(_ dtos: [CategoryDTO])
    func upsertBrands(_ dtos: [BrandDTO])
}
