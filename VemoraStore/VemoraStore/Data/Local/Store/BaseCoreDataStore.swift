//
//  BaseCoreDataStore.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import CoreData

/// Базовый класс для всех Core Data-хранилищ (Profile, Catalog, Favorites, Cart и т.д.).
///
/// Отвечает за:
/// - инициализацию и конфигурацию общего `NSPersistentContainer`;
/// - предоставление настроенных контекстов:
///   - `viewContext` — для чтения и FRC-наблюдения;
///   - `bg` — для фоновых операций записи/апдейта;
/// - автоматическое объединение изменений `bg → viewContext` через `NotificationCenter`;
/// - утилиты для безопасного выполнения и сохранения фоновых операций.
///
/// Особенности реализации:
/// - `viewContext` и `bg` настраиваются с политикой `NSMergeByPropertyObjectTrumpMergePolicy`;
/// - `viewContext` имеет `automaticallyMergesChangesFromParent = true` для синхронизации данных в UI;
/// - `bg` не использует `undoManager` для снижения overhead;
/// - при `save(bg)` происходит автоматический merge изменений в главный контекст;
/// - предусмотрены вспомогательные методы `performInBackground` и `saveBackgroundIfNeeded`
///   для упрощения работы в фоновых очередях без гонок и крашей.

class BaseCoreDataStore {
    
    // MARK: - Deps
    
    let container: NSPersistentContainer
    
    // MARK: - Contexts
    
    /// Главный контекст (UI / FRC)
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    /// Фоновый контекст (записи/апдейты)
    let bg: NSManagedObjectContext
    
    private var bgSaveObserver: NSObjectProtocol?
    
    // MARK: - Init
    
    /// Инжектируем общий NSPersistentContainer (должен быть один и тот же во всём модуле).
    init(container: NSPersistentContainer) {
        self.container = container
        
        // Убедимся, что viewContext настроен
        BaseCoreDataStore.configureViewContext(container.viewContext)
        
        // Создаём и настраиваем background context
        let background = container.newBackgroundContext()
        BaseCoreDataStore.configureBackgroundContext(background)
        self.bg = background
        
        // Подписываемся: save(bg) -> merge в viewContext
        self.bgSaveObserver = NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: background,
            queue: nil
        ) { [weak viewContext = container.viewContext] note in
            viewContext?.perform {
                viewContext?.mergeChanges(fromContextDidSave: note)
            }
        }
    }
    
    deinit {
        if let token = bgSaveObserver {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    // MARK: - Helpers
    
    /// Выполнить блок на фоне
    func performInBackground(_ block: @escaping (NSManagedObjectContext) -> Void) {
        bg.perform { [weak self] in
            guard let self else { return }
            block(self.bg)
        }
    }
    
    /// Сохранить фон, если есть изменения (без краша наружу)
    func saveBackgroundIfNeeded() {
        bg.perform { [weak self] in
            guard let self else { return }
            guard self.bg.hasChanges else { return }
            do { try self.bg.save() }
            catch { print("❌ BaseCoreDataStore: bg save error \(error)") }
        }
    }
}

// MARK: - Configuration

extension BaseCoreDataStore {
    static func configureViewContext(_ context: NSManagedObjectContext) {
        context.name = context.name ?? "viewContext"
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.shouldDeleteInaccessibleFaults = true
    }
    
    static func configureBackgroundContext(_ context: NSManagedObjectContext) {
        context.name = context.name ?? "bgContext"
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil
    }
}
