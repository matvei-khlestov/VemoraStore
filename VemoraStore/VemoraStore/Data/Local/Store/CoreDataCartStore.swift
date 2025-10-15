//
//  CoreDataCartStore.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 11.10.2025.
//

import CoreData
import Combine

final class CoreDataCartStore: BaseCoreDataStore, CartLocalStore {

    private var streams: [String: CartFRCPublisher] = [:]

    override init(container: NSPersistentContainer) {
        super.init(container: container)
    }

    func observeItems(userId: String) -> AnyPublisher<[CartItem], Never> {
        if let s = streams[userId] { return s.publisher() }
        let s = CartFRCPublisher(context: viewContext, userId: userId)
        streams[userId] = s
        return s.publisher()
    }

    func snapshot(userId: String) -> [CartItem]? {
        var result: [CartItem]?
        let context = viewContext

        context.performAndWait {
            do {
                let req: NSFetchRequest<CDCartItem> = CDCartItem.fetchRequest()
                req.predicate = NSPredicate(format: "userId == %@", userId)
                req.sortDescriptors = [
                    NSSortDescriptor(key: "updatedAt", ascending: false)
                ]
                let entities = try context.fetch(req)
                result = entities.map { $0.toCartItem() }
            } catch {
                print("❌ CoreDataCartStore.snapshot error: \(error)")
                result = nil
            }
        }
        return result
    }

    func replaceAll(userId: String, with dtos: [CartDTO]) {
        bg.perform {
            do {
                let req: NSFetchRequest<CDCartItem> = CDCartItem.fetchRequest()
                req.predicate = NSPredicate(format: "userId == %@", userId)
                let existing = try self.bg.fetch(req)
                existing.forEach { self.bg.delete($0) }

                for dto in dtos {
                    let e = CDCartItem(context: self.bg)
                    e.apply(dto: dto)
                }

                guard self.bg.hasChanges else { return }
                try self.bg.save()
            } catch {
                print("❌ CoreDataCartStore.replaceAll error: \(error)")
            }
        }
    }

    func upsert(userId: String, dto: CartDTO, accumulate: Bool) {
        bg.perform {
            do {
                let req: NSFetchRequest<CDCartItem> = CDCartItem.fetchRequest()
                req.predicate = NSPredicate(format: "userId == %@ AND productId == %@", userId, dto.productId)
                req.fetchLimit = 1
                let entity = try self.bg.fetch(req).first ?? CDCartItem(context: self.bg)

                if entity.userId == nil { entity.userId = userId }
                if entity.productId == nil { entity.productId = dto.productId }

                if accumulate, let qty = entity.value(forKey: "quantity") as? Int32 {
                    let newQty = max(0, Int(qty) + dto.quantity)
                    entity.title = dto.title
                    entity.brandName = dto.brandName
                    entity.price = dto.price
                    entity.imageURL = dto.imageURL
                    entity.quantity = Int32(newQty)
                    entity.updatedAt = dto.updatedAt
                } else {
                    entity.apply(dto: dto)
                }

                guard self.bg.hasChanges else { return }
                try self.bg.save()
            } catch {
                print("❌ CoreDataCartStore.upsert error: \(error)")
            }
        }
    }

    func setQuantity(userId: String, productId: String, quantity: Int) {
        bg.perform {
            do {
                let req: NSFetchRequest<CDCartItem> = CDCartItem.fetchRequest()
                req.predicate = NSPredicate(format: "userId == %@ AND productId == %@", userId, productId)
                req.fetchLimit = 1
                guard let entity = try self.bg.fetch(req).first else { return }
                if quantity <= 0 {
                    self.bg.delete(entity)
                } else {
                    entity.quantity = Int32(quantity)
                    entity.updatedAt = Date()
                }
                guard self.bg.hasChanges else { return }
                try self.bg.save()
            } catch {
                print("❌ CoreDataCartStore.setQuantity error: \(error)")
            }
        }
    }

    func remove(userId: String, productId: String) {
        bg.perform {
            do {
                let req: NSFetchRequest<CDCartItem> = CDCartItem.fetchRequest()
                req.predicate = NSPredicate(format: "userId == %@ AND productId == %@", userId, productId)
                req.fetchLimit = 1
                if let e = try self.bg.fetch(req).first {
                    self.bg.delete(e)
                    guard self.bg.hasChanges else { return }
                    try self.bg.save()
                }
            } catch {
                print("❌ CoreDataCartStore.remove error: \(error)")
            }
        }
    }

    func clear(userId: String) {
        bg.perform {
            do {
                let req: NSFetchRequest<CDCartItem> = CDCartItem.fetchRequest()
                req.predicate = NSPredicate(format: "userId == %@", userId)
                let objs = try self.bg.fetch(req)
                objs.forEach { self.bg.delete($0) }
                guard self.bg.hasChanges else { return }
                try self.bg.save()
                print("🧹 CoreDataCartStore: cleared profile for uid=\(userId)")
            } catch {
                print("❌ CoreDataCartStore.clear error: \(error)")
            }
        }
    }
}
