//
//  ProductsFRCPublisher.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import CoreData
import Combine

final class ProductsFRCPublisher: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Output
    
    private let subject = CurrentValueSubject<[Product], Never>([])
    func publisher() -> AnyPublisher<[Product], Never> { subject.eraseToAnyPublisher() }
    
    // MARK: - FRC
    
    private let frc: NSFetchedResultsController<CDProduct>
    
    // MARK: - Filters (Options)
    
    struct Options: Equatable {
        var query: String?
        var categoryIds: Set<String>?
        var brandIds: Set<String>?
        var minPrice: Decimal?
        var maxPrice: Decimal?
        
        init(
            query: String? = nil,
            categoryIds: Set<String>? = nil,
            brandIds: Set<String>? = nil,
            minPrice: Decimal? = nil,
            maxPrice: Decimal? = nil
        ) {
            self.query = query
            self.categoryIds = categoryIds
            self.brandIds = brandIds
            self.minPrice = minPrice
            self.maxPrice = maxPrice
        }
    }
    
    // MARK: - Designated init (инъекция FRC для тестов)
    
    init(frc: NSFetchedResultsController<CDProduct>) {
        self.frc = frc
        super.init()
        self.frc.delegate = self
    }
    
    // MARK: - Convenience init (prod)
    
    convenience init(context: NSManagedObjectContext, options: Options) {
        let request = Self.makeRequest(options: options)
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        self.init(frc: frc)
        performInitialFetch(on: context)
#if DEBUG
        print("ProductsFRCPublisher options: \(options)")
#endif
    }
    
    convenience init(
        context: NSManagedObjectContext,
        query: String?,
        categoryId: String?
    ) {
        self.init(
            context: context,
            options: .init(query: query, categoryIds: categoryId.map { [$0] })
        )
    }
    
    deinit { frc.delegate = nil }
    
    // MARK: - Initial fetch
    
    private func performInitialFetch(on context: NSManagedObjectContext) {
        context.perform { [weak self] in
            guard let self else { return }
            do {
                try self.frc.performFetch()
                let items = (self.frc.fetchedObjects ?? []).compactMap(Product.init(cd:))
#if DEBUG
                print("ProductsFRCPublisher initial count=\(items.count)")
#endif
                self.subject.send(items)
            } catch {
#if DEBUG
                print("❌ ProductsFRCPublisher fetch error:", error)
#endif
                self.subject.send([])
            }
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        let items = (controller.fetchedObjects as? [CDProduct])?.compactMap(Product.init(cd:)) ?? []
#if DEBUG
        print("ProductsFRCPublisher didChange count=\(items.count)")
#endif
        subject.send(items)
    }
}

// MARK: - Request builder

private extension ProductsFRCPublisher {
    
    static func makeRequest(options: Options) -> NSFetchRequest<CDProduct> {
        let req: NSFetchRequest<CDProduct> = CDProduct.fetchRequest()
        req.fetchBatchSize = 40
        req.returnsObjectsAsFaults = false
        
        var predicates: [NSPredicate] = [
            NSPredicate(format: "isActive == YES"),
            NSPredicate(format: "categoryIsActive == YES")
        ]
        
        if let q = options.query?.trimmingCharacters(in: .whitespacesAndNewlines), !q.isEmpty {
            let qLower = q.lowercased()
            let byName = NSPredicate(format: "nameLower CONTAINS[cd] %@", qLower)
            let byKeywords = NSPredicate(format: "keywordsIndex CONTAINS[cd] %@", qLower)
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [byName, byKeywords]))
        }
        
        if let cids = options.categoryIds, !cids.isEmpty {
            predicates.append(NSPredicate(format: "categoryId IN %@", Array(cids)))
        }
        
        if let bids = options.brandIds, !bids.isEmpty {
            predicates.append(NSPredicate(format: "brandId IN %@", Array(bids)))
        }
        
        if let min = options.minPrice {
            predicates.append(NSPredicate(format: "price >= %f", (min as NSDecimalNumber).doubleValue))
        }
        if let max = options.maxPrice {
            predicates.append(NSPredicate(format: "price <= %f", (max as NSDecimalNumber).doubleValue))
        }
        
        req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        req.sortDescriptors = [
            NSSortDescriptor(key: "id", ascending: false),
            NSSortDescriptor(key: "categoryId", ascending: false),
            NSSortDescriptor(key: "brandId", ascending: false)
        ]
        return req
    }
}
