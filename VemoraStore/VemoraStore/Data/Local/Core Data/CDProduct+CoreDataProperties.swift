//
//  CDProduct+CoreDataProperties.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//
//

import Foundation
import CoreData


extension CDProduct {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDProduct> {
        return NSFetchRequest<CDProduct>(entityName: "CDProduct")
    }

    @NSManaged public var brandId: String?
    @NSManaged public var categoryId: String?
    @NSManaged public var categoryIsActive: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var desc: String?
    @NSManaged public var id: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var keywords: [String]?
    @NSManaged public var keywordsIndex: String?
    @NSManaged public var name: String?
    @NSManaged public var nameLower: String?
    @NSManaged public var price: Double
    @NSManaged public var updatedAt: Date?

}

extension CDProduct : Identifiable {

}
