//
//  AppPersistent.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import CoreData

enum AppPersistent {
    static let shared: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "VemoraStore")
        container.loadPersistentStores { _, error in
            if let error { fatalError("CoreData load error: \(error)") }
        }
        let ctx = container.viewContext
        ctx.automaticallyMergesChangesFromParent = true
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        ctx.shouldDeleteInaccessibleFaults = true
        return container
    }()
}
