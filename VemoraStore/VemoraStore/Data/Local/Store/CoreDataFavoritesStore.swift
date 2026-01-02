//
//  CoreDataFavoritesStore.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.10.2025.
//

import Combine
import CoreData

/// Локальное хранилище избранного на Core Data.
///
/// Отвечает за:
/// - реактивное наблюдение элементов избранного конкретного пользователя (через FRC);
/// - массовую замену снапшота (sync) из DTO;
/// - upsert/удаление отдельных элементов;
/// - очистку избранного пользователя.
///
/// Особенности:
/// - все записи/удаления выполняются на фоновой очереди `bg`;
/// - чтение/наблюдение — через `viewContext`;
/// - FRC-паблишеры кешируются по `userId` в `streams`;
/// - `save()` вызывается только при наличии изменений.
///
/// Используется в `FavoritesRepository` как локальный слой.

final class CoreDataFavoritesStore: BaseCoreDataStore, FavoritesLocalStore {
    
    private var streams: [String: FavoritesFRCPublisher] = [:]
    
    // MARK: - Observe
    
    func observeItems(userId: String) -> AnyPublisher<[FavoriteItem], Never> {
        if let s = streams[userId] { return s.publisher() }
        let s = FavoritesFRCPublisher(context: viewContext, userId: userId)
        streams[userId] = s
        return s.publisher()
    }
    
    // MARK: - CRUD
    
    func replaceAll(userId: String, with dtos: [FavoriteDTO]) {
        bg.perform {
            do {
                let req: NSFetchRequest<CDFavoriteItem> = CDFavoriteItem.fetchRequest()
                req.predicate = NSPredicate(format: "userId == %@", userId)
                let existing = try self.bg.fetch(req)
                existing.forEach { self.bg.delete($0) }
                
                for dto in dtos {
                    let e = CDFavoriteItem(context: self.bg)
                    e.apply(dto: dto)
                }
                
                guard self.bg.hasChanges else { return }
                try self.bg.save()
            } catch {
                print("❌ CoreDataFavoritesStore.replaceAll error: \(error)")
            }
        }
    }
    
    func upsert(userId: String, dto: FavoriteDTO) {
        bg.perform {
            do {
                let req: NSFetchRequest<CDFavoriteItem> = CDFavoriteItem.fetchRequest()
                req.predicate = NSPredicate(format: "userId == %@ AND productId == %@", userId, dto.productId)
                req.fetchLimit = 1
                let entity = try self.bg.fetch(req).first ?? CDFavoriteItem(context: self.bg)
                
                if entity.userId == nil { entity.userId = userId }
                if entity.productId == nil { entity.productId = dto.productId }
                
                entity.apply(dto: dto)
                
                guard self.bg.hasChanges else { return }
                try self.bg.save()
            } catch {
                print("❌ CoreDataFavoritesStore.upsert error: \(error)")
            }
        }
    }
    
    func remove(userId: String, productId: String) {
        bg.perform {
            do {
                let req: NSFetchRequest<CDFavoriteItem> = CDFavoriteItem.fetchRequest()
                req.predicate = NSPredicate(format: "userId == %@ AND productId == %@", userId, productId)
                req.fetchLimit = 1
                
                if let entity = try self.bg.fetch(req).first {
                    self.bg.delete(entity)
                    guard self.bg.hasChanges else { return }
                    try self.bg.save()
                }
            } catch {
                print("❌ CoreDataFavoritesStore.remove error: \(error)")
            }
        }
    }
    
    func clear(userId: String) {
        bg.perform {
            do {
                let req: NSFetchRequest<CDFavoriteItem> = CDFavoriteItem.fetchRequest()
                req.predicate = NSPredicate(format: "userId == %@", userId)
                let objs = try self.bg.fetch(req)
                objs.forEach { self.bg.delete($0) }
                
                guard self.bg.hasChanges else { return }
                try self.bg.save()
                print("🧹 CoreDataFavoritesStore: cleared favorites for uid=\(userId)")
            } catch {
                print("❌ CoreDataFavoritesStore.clear error: \(error)")
            }
        }
    }
}
