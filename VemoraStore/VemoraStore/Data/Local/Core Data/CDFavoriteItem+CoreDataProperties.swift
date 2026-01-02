//
//  CDFavoriteItem+CoreDataProperties.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.10.2025.
//
//

import Foundation
import CoreData

extension CDFavoriteItem {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDFavoriteItem> {
        return NSFetchRequest<CDFavoriteItem>(entityName: "CDFavoriteItem")
    }
    
    @NSManaged public var userId: String?
    @NSManaged public var productId: String?
    @NSManaged public var brandName: String?
    @NSManaged public var title: String?
    @NSManaged public var price: Double
    @NSManaged public var imageURL: String?
    @NSManaged public var updatedAt: Date?
}

extension CDFavoriteItem : Identifiable {}
