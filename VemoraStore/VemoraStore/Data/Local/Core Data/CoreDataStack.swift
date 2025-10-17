//
//  CoreDataStack.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import CoreData

/// Core Data стек приложения.
///
/// Обеспечивает:
/// - конфигурацию `NSPersistentContainer` c `persistentStoreDescriptions`
///   (авто-миграции, защита файла, при необходимости — history tracking);
/// - загрузку стора с политикой восстановления при сбое миграции
///   (одноразовый wipe `.sqlite/.sqlite-wal/.sqlite-shm` + повторная загрузка);
/// - доступ к основному (`viewContext`) и фоновым (`newBackgroundContext`) контекстам;
/// - единые политики мерджа и сохранения контекстов.
///
/// Использование:
/// - `CoreDataStack.shared` — готовый экземпляр со схемой *VemoraStore*;
/// - для фоновых операций вызывайте `newBackgroundContext()`
///   (контекст уже сконфигурирован и готов к использованию).

final class CoreDataStack {
    
    // MARK: - Shared instance
    
    static let shared = CoreDataStack(modelName: "VemoraStore")
    
    // MARK: - Properties
    
    /// Флаг, чтобы не зациклиться на восстановлении стора
    private var didAttemptRecovery = false
    
    /// Контейнер Core Data, инкапсулирующий модель, контексты и хранилище.
    let container: NSPersistentContainer
    
    /// Основной контекст (используется на главном потоке для UI и чтения данных).
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    /// Фоновый контекст для фоновых операций записи и синхронизации.
    var backgroundContext: NSManagedObjectContext {
        let ctx = container.newBackgroundContext()
        CoreDataStack.configureBackgroundContext(ctx)
        return ctx
    }
    
    // MARK: - Init
    
    /// Инициализирует Core Data стек, создавая контейнер и конфигурируя persistent store.
    init(modelName: String) {
        container = NSPersistentContainer(name: modelName)
        container.persistentStoreDescriptions = [
            Self.makeStoreDescription(modelName: modelName)
        ]
        loadStoresWithRecovery()
        CoreDataStack.configureViewContext(container.viewContext)
    }
    
    // MARK: - Store description
    
    /// Формирует описание стора с авто-миграцией, защитой файла и history tracking.
    private static func makeStoreDescription(
        modelName: String,
        enableHistoryTracking: Bool = true,
        fileProtection: FileProtectionType = .completeUntilFirstUserAuthentication
    ) -> NSPersistentStoreDescription {
        
        let d = NSPersistentStoreDescription()
        d.type = NSSQLiteStoreType
        d.url  = NSPersistentContainer.defaultDirectoryURL()
            .appendingPathComponent("\(modelName).sqlite")
        
        d.setOption(
            true as NSNumber,
            forKey: NSMigratePersistentStoresAutomaticallyOption
        )
        d.setOption(
            true as NSNumber,
            forKey: NSInferMappingModelAutomaticallyOption
        )
        
        d.setOption(
            fileProtection as NSObject,
            forKey: NSPersistentStoreFileProtectionKey
        )
        
        if enableHistoryTracking {
            d.setOption(
                true as NSNumber, forKey: NSPersistentHistoryTrackingKey
            )
        }
        return d
    }
    
    // MARK: - Load with recovery
    
    /// Загружает persistent store с попыткой восстановления при сбое миграции.
    private func loadStoresWithRecovery() {
        container.loadPersistentStores { desc, error in
            guard let error else { return }
            if !self.didAttemptRecovery, let url = desc.url {
                self.didAttemptRecovery = true
                self.wipeStoreFiles(at: url)
                self.container.loadPersistentStores { _, secondError in
                    if let secondError {
                        assertionFailure("CoreData load (after recovery) error: \(secondError)")
                    }
                }
            } else {
                assertionFailure("CoreData load error: \(error)")
            }
        }
    }
    
    // MARK: - Recovery helpers & Migration policy
    
    /// Удаляет файлы стора (`.sqlite`, `.sqlite-wal`, `.sqlite-shm`)
    /// для попытки восстановления при коррапте или сбое миграции.
    private func wipeStoreFiles(at url: URL) {
        let fm = FileManager.default
        let baseName = url.deletingPathExtension().lastPathComponent
        let dir = url.deletingLastPathComponent()
        
        let sqliteURL = dir.appendingPathComponent("\(baseName).sqlite")
        let walURL = dir.appendingPathComponent("\(baseName).sqlite-wal")
        let shmURL = dir.appendingPathComponent("\(baseName).sqlite-shm")
        
        for fileURL in [sqliteURL, walURL, shmURL] {
            do {
                if fm.fileExists(atPath: fileURL.path) {
                    try fm.removeItem(at: fileURL)
                }
            } catch {
                print("⚠️ CoreDataStack: wipeStoreFiles error for \(fileURL.lastPathComponent): \(error)")
            }
        }
    }
    
    // MARK: - Context creation
    
    /// Создаёт и возвращает новый сконфигурированный фоновый контекст.
    func newBackgroundContext() -> NSManagedObjectContext {
        let ctx = container.newBackgroundContext()
        CoreDataStack.configureBackgroundContext(ctx)
        return ctx
    }
    
    // MARK: - Saves
    
    /// Сохраняет изменения viewContext, если они есть.
    func saveViewContextIfNeeded() throws {
        try save(container.viewContext)
    }
    
    /// Сохраняет указанный контекст, если в нём есть изменения.
    func save(_ context: NSManagedObjectContext) throws {
        guard context.hasChanges else { return }
        try context.save()
    }
    
    // MARK: - Configuration
    
    /// Настраивает viewContext: merge policy, автоматический мердж, fault cleanup.
    private static func configureViewContext(_ context: NSManagedObjectContext) {
        context.name = "viewContext"
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.shouldDeleteInaccessibleFaults = true
    }
    
    /// Настраивает backgroundContext: merge policy, отключает undoManager.
    private static func configureBackgroundContext(_ context: NSManagedObjectContext) {
        context.name = "bgContext"
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil
    }
}
