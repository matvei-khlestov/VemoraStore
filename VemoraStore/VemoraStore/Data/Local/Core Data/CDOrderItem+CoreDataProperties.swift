//
//  CDOrderItem+CoreDataProperties.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//
//

import Foundation
import CoreData

extension CDOrderItem {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDOrderItem> {
        return NSFetchRequest<CDOrderItem>(entityName: "CDOrderItem")
    }
    
    @NSManaged public var productId: String?
    @NSManaged public var brandName: String?
    @NSManaged public var title: String?
    @NSManaged public var price: Double
    @NSManaged public var imageURL: String?
    @NSManaged public var quantity: Int32
    @NSManaged public var order: CDOrder?
    
}

extension CDOrderItem : Identifiable {}
