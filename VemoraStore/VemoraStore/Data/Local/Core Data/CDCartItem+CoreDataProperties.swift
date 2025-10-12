//
//  CDCartItem+CoreDataProperties.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.10.2025.
//
//

import Foundation
import CoreData

extension CDCartItem {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDCartItem> {
        return NSFetchRequest<CDCartItem>(entityName: "CDCartItem")
    }
    
    @NSManaged public var userId: String?
    @NSManaged public var productId: String?
    @NSManaged public var brandName: String?
    @NSManaged public var title: String?
    @NSManaged public var price: Double
    @NSManaged public var imageURL: String?
    @NSManaged public var quantity: Int32
    @NSManaged public var updatedAt: Date?
    
}

extension CDCartItem : Identifiable {}
