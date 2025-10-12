//
//  CDProduct+FetchOrCreate.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 11.10.2025.
//

import CoreData

extension CDProduct {
    static func fetchOrCreate(withId id: String, in ctx: NSManagedObjectContext) -> CDProduct {
        let req: NSFetchRequest<CDProduct> = CDProduct.fetchRequest()
        req.fetchLimit = 1
        req.predicate = NSPredicate(format: "id == %@", id)
        if let found = try? ctx.fetch(req).first { return found }
        let created = CDProduct(context: ctx)
        created.id = id
        return created
    }
}
