//
//  CoreDataStack.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import CoreData

final class CoreDataStack {
    
    // MARK: - Shared instance
    
    static let shared = CoreDataStack(modelName: "VemoraStore")
    
    // MARK: - Properties
    
    let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext {
        let ctx = container.newBackgroundContext()
        CoreDataStack.configureBackgroundContext(ctx)
        return ctx
    }
    
    // MARK: - Init
    
    init(modelName: String) {
        container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("❌ CoreData load error: \(error)")
            }
        }
        CoreDataStack.configureViewContext(container.viewContext)
    }
    
    // MARK: - Context creation
   
    func newBackgroundContext() -> NSManagedObjectContext {
        let ctx = container.newBackgroundContext()
        CoreDataStack.configureBackgroundContext(ctx)
        return ctx
    }
    
    // MARK: - Saves
    
    func saveViewContextIfNeeded() throws {
        try save(container.viewContext)
    }
    
    func save(_ context: NSManagedObjectContext) throws {
        guard context.hasChanges else { return }
        try context.save()
    }
    
    // MARK: - Configuration
    
    private static func configureViewContext(_ context: NSManagedObjectContext) {
        context.name = "viewContext"
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.shouldDeleteInaccessibleFaults = true
    }
    
    private static func configureBackgroundContext(_ context: NSManagedObjectContext) {
        context.name = "bgContext"
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil
    }
}
