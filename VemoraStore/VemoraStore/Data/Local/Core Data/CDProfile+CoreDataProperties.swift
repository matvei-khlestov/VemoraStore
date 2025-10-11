//
//  CDProfile+CoreDataProperties.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//
//

import Foundation
import CoreData

extension CDProfile {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDProfile> {
        return NSFetchRequest<CDProfile>(entityName: "CDProfile")
    }
    
    @NSManaged public var userId: String?
    @NSManaged public var name: String?
    @NSManaged public var email: String?
    @NSManaged public var phone: String?
    @NSManaged public var updatedAt: Date?
}

extension CDProfile : Identifiable {}
