//
//  CDCategory+CoreDataProperties.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//
//

import Foundation
import CoreData

extension CDCategory {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDCategory> {
        return NSFetchRequest<CDCategory>(entityName: "CDCategory")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var brandIds: [String]?
    @NSManaged public var isActive: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
}

extension CDCategory : Identifiable {}
