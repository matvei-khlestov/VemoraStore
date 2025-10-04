//
//  CoreDataRepository.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import CoreData
import Combine

final class CoreDataRepository: LocalStore {
    
    // MARK: - Deps
    
    private let container: NSPersistentContainer
    
    // MARK: - Contexts
    
    private let bg: NSManagedObjectContext
    private var bgSaveObserver: NSObjectProtocol?
    
    // MARK: - Streams cache
    
    private var profileStreams: [String: ProfileFRCPublisher] = [:]
    
    // MARK: - Init
    
    /// Инжектируем контейнер. ВАЖНО: этот же контейнер должен использоваться во всём модуле.
    init(container: NSPersistentContainer) {
        self.container = container
        
        // viewContext — убеждаемся, что сконфигурирован корректно
        Self.configureViewContext(container.viewContext)
        
        // backgroundContext — создаём из ТОГО ЖЕ контейнера
        let background = container.newBackgroundContext()
        Self.configureBackgroundContext(background)
        self.bg = background
        
        // Подписка: сохраняем bg → мерджим во viewContext
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
    
    // MARK: - LocalStore
    
    func observeProfile(userId: String) -> AnyPublisher<UserProfile?, Never> {
        if let stream = profileStreams[userId] {
            return stream.publisher()
        }
        let stream = ProfileFRCPublisher(context: container.viewContext, userId: userId)
        profileStreams[userId] = stream
        return stream.publisher()
    }
    
    func upsertProfile(_ dto: ProfileDTO) {
        bg.perform {
            do {
                // 1) Ищем текущую запись
                let req: NSFetchRequest<CDProfile> = CDProfile.fetchRequest()
                req.predicate = NSPredicate(format: "userId == %@", dto.userId)
                req.fetchLimit = 1
                
                let existing = try self.bg.fetch(req).first
                
                // 2) Если всё совпадает — ничего не делаем
                if let existing, existing.matches(dto) {
                    return
                }
                
                // 3) Создаём/обновляем
                let entity = existing ?? CDProfile(context: self.bg)
                if existing == nil { entity.userId = dto.userId }
                entity.apply(dto: dto)
                
                // 4) Сохраняем, только если реально есть изменения
                guard self.bg.hasChanges else { return }
                try self.bg.save()
                print("✅ LocalStoreCoreData: saved profile dto for uid=\(dto.userId)")
            } catch {
                print("❌ LocalStoreCoreData: save error \(error)")
            }
        }
    }
}

// MARK: - Setup helpers

private extension CoreDataRepository {
    static func configureViewContext(_ context: NSManagedObjectContext) {
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.shouldDeleteInaccessibleFaults = true
        context.name = context.name ?? "viewContext"
    }
    
    static func configureBackgroundContext(_ context: NSManagedObjectContext) {
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.name = context.name ?? "bgContext"
        // context.undoManager = nil // при желании отключить undo
    }
}
