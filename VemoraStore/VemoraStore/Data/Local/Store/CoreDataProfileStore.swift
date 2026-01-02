//
//  CoreDataProfileStore.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 04.10.2025.
//

import CoreData
import Combine

/// Локальное хранилище профиля пользователя на Core Data.
///
/// Отвечает за:
/// - хранение и обновление данных профиля пользователя локально;
/// - реактивное наблюдение за изменениями профиля через `ProfileFRCPublisher`;
/// - очистку данных при смене пользователя или логауте.
///
/// Особенности реализации:
/// - чтение/наблюдение выполняется на `viewContext`, запись — на фоновой `bg` очереди;
/// - стримы профилей кешируются по `userId` в словаре `profileStreams`;
/// - перед сохранением выполняется сравнение (`matches`) для предотвращения лишних операций;
/// - `save()` вызывается только при наличии изменений (`hasChanges`);
/// - при очистке удаляются все записи и соответствующий кеш стрима.

final class CoreDataProfileStore: BaseCoreDataStore, ProfileLocalStore {
    
    // MARK: - Streams cache
    
    private var profileStreams: [String: ProfileFRCPublisher] = [:]
    
    // MARK: - Init
    
    override init(container: NSPersistentContainer) {
        super.init(container: container)
    }
    
    // MARK: - ProfileLocalStore
    
    func observeProfile(userId: String) -> AnyPublisher<UserProfile?, Never> {
        if let stream = profileStreams[userId] {
            return stream.publisher()
        }
        let stream = ProfileFRCPublisher(context: viewContext, userId: userId)
        profileStreams[userId] = stream
        return stream.publisher()
    }
    
    func upsertProfile(_ dto: ProfileDTO) {
        bg.perform {
            do {
                let req: NSFetchRequest<CDProfile> = CDProfile.fetchRequest()
                req.predicate = NSPredicate(format: "userId == %@", dto.userId)
                req.fetchLimit = 1
                
                let existing = try self.bg.fetch(req).first
                
                // Нечего писать — всё совпало
                if let existing, existing.matches(dto) { return }
                
                let entity = existing ?? CDProfile(context: self.bg)
                if existing == nil { entity.userId = dto.userId }
                entity.apply(dto: dto)
                
                guard self.bg.hasChanges else { return }
                try self.bg.save()
                print("✅ CoreDataProfileStore: saved profile dto for uid=\(dto.userId)")
            } catch {
                print("❌ CoreDataProfileStore: save error \(error)")
            }
        }
    }
    
    // MARK: - Clear (для смены пользователя / логаута)
    
    func clear(userId: String) {
        bg.perform {
            do {
                let req: NSFetchRequest<CDProfile> = CDProfile.fetchRequest()
                req.predicate = NSPredicate(format: "userId == %@", userId)
                let objs = try self.bg.fetch(req)
                objs.forEach { self.bg.delete($0) }
                
                guard self.bg.hasChanges else { return }
                try self.bg.save()
                print("🧹 CoreDataProfileStore: cleared profile for uid=\(userId)")
            } catch {
                print("❌ CoreDataProfileStore.clear error: \(error)")
            }
        }
        
        profileStreams[userId] = nil
    }
}
