//
//  CDBrand+CoreDataProperties.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 09.10.2025.
//
//

import Foundation
import CoreData

extension CDBrand {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDBrand> {
        return NSFetchRequest<CDBrand>(entityName: "CDBrand")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    
}

extension CDBrand : Identifiable {}
