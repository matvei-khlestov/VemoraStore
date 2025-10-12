//
//  CoreDataFavoritesStore.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.10.2025.
//

import Combine
import CoreData

final class CoreDataFavoritesStore: BaseCoreDataStore, FavoritesLocalStore {
    
    private var streams: [String: FavoritesFRCPublisher] = [:]
    
    func observeItems(userId: String) -> AnyPublisher<[FavoriteItem], Never> {
        if let s = streams[userId] { return s.publisher() }
        let s = FavoritesFRCPublisher(context: viewContext, userId: userId)
        streams[userId] = s
        return s.publisher()
    }
    
    func replaceAll(userId: String, with dtos: [FavoriteDTO]) {
        bg.perform {
            let req: NSFetchRequest<CDFavoriteItem> = CDFavoriteItem.fetchRequest()
            req.predicate = NSPredicate(format: "userId == %@", userId)
            let existing = try? self.bg.fetch(req)
            existing?.forEach { self.bg.delete($0) }
            dtos.forEach { dto in
                let e = CDFavoriteItem(context: self.bg)
                e.apply(dto: dto)
            }
            try? self.bg.save()
        }
    }
    
    func upsert(userId: String, dto: FavoriteDTO) {
        bg.perform {
            let req: NSFetchRequest<CDFavoriteItem> = CDFavoriteItem.fetchRequest()
            req.predicate = NSPredicate(format: "userId == %@ AND productId == %@", userId, dto.productId)
            req.fetchLimit = 1
            let entity = (try? self.bg.fetch(req).first) ?? CDFavoriteItem(context: self.bg)
            if entity.userId == nil { entity.userId = userId }
            if entity.productId == nil { entity.productId = dto.productId }
            entity.apply(dto: dto)
            try? self.bg.save()
        }
    }
    
    func remove(userId: String, productId: String) {
        bg.perform {
            let req: NSFetchRequest<CDFavoriteItem> = CDFavoriteItem.fetchRequest()
            req.predicate = NSPredicate(format: "userId == %@ AND productId == %@", userId, productId)
            req.fetchLimit = 1
            if let e = try? self.bg.fetch(req).first {
                self.bg.delete(e)
                try? self.bg.save()
            }
        }
    }
    
    func clear(userId: String) {
        bg.perform {
            let req: NSFetchRequest<CDFavoriteItem> = CDFavoriteItem.fetchRequest()
            req.predicate = NSPredicate(format: "userId == %@", userId)
            let objs = (try? self.bg.fetch(req)) ?? []
            objs.forEach { self.bg.delete($0) }
            try? self.bg.save()
        }
    }
}
