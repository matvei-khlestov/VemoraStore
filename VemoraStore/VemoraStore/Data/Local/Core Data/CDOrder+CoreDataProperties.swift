//
//  CDOrder+CoreDataProperties.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//
//

import Foundation
import CoreData

extension CDOrder {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDOrder> {
        return NSFetchRequest<CDOrder>(entityName: "CDOrder")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var userId: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var status: String?
    @NSManaged public var receiveAddress: String?
    @NSManaged public var paymentMethod: String?
    @NSManaged public var comment: String?
    @NSManaged public var phoneE164: String?
    @NSManaged public var items: NSSet?
}

// MARK: Generated accessors for items
extension CDOrder {
    
    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: CDOrderItem)
    
    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: CDOrderItem)
    
    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)
    
    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)
    
}

extension CDOrder : Identifiable {}
