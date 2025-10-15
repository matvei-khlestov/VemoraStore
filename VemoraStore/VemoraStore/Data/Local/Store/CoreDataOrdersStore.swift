//
//  CoreDataOrdersStore.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Foundation
import CoreData
import Combine

final class CoreDataOrdersStore: BaseCoreDataStore, OrdersLocalStore {
    
    private var streams: [String: OrdersFRCPublisher] = [:]
    
    override init(container: NSPersistentContainer) {
        super.init(container: container)
    }
    
    func observeOrders(userId: String) -> AnyPublisher<[OrderEntity], Never> {
        if let s = streams[userId] { return s.publisher() }
        let s = OrdersFRCPublisher(context: viewContext, userId: userId)
        streams[userId] = s
        return s.publisher()
    }
    
    func replaceAll(userId: String, with dtos: [OrderDTO]) {
        bg.perform {
            do {
                // Удаляем все старые заказы пользователя
                let req: NSFetchRequest<CDOrder> = CDOrder.fetchRequest()
                req.predicate = NSPredicate(format: "userId == %@", userId)
                let existing = try self.bg.fetch(req)
                existing.forEach { self.bg.delete($0) }
                
                // Вставляем новые
                for dto in dtos {
                    let e = CDOrder(context: self.bg)
                    e.apply(dto: dto, ctx: self.bg)
                }
                
                guard self.bg.hasChanges else { return }
                try self.bg.save()
            } catch {
                print("❌ CoreDataOrdersStore.replaceAll error: \(error)")
            }
        }
    }
    
    func upsert(userId: String, dto: OrderDTO) {
        bg.perform {
            do {
                let req: NSFetchRequest<CDOrder> = CDOrder.fetchRequest()
                req.predicate = NSPredicate(format: "userId == %@ AND id == %@", userId, dto.id)
                req.fetchLimit = 1
                let entity = try self.bg.fetch(req).first ?? CDOrder(context: self.bg)
                entity.apply(dto: dto, ctx: self.bg)
                
                guard self.bg.hasChanges else { return }
                try self.bg.save()
            } catch {
                print("❌ CoreDataOrdersStore.upsert error: \(error)")
            }
        }
    }
    
    func updateStatus(userId: String, orderId: String, status: OrderStatus) {
        bg.perform {
            do {
                let req: NSFetchRequest<CDOrder> = CDOrder.fetchRequest()
                req.predicate = NSPredicate(format: "userId == %@ AND id == %@", userId, orderId)
                req.fetchLimit = 1
                guard let e = try self.bg.fetch(req).first else { return }
                e.status = status.rawValue
                e.updatedAt = Date()
                guard self.bg.hasChanges else { return }
                try self.bg.save()
            } catch {
                print("❌ CoreDataOrdersStore.updateStatus error: \(error)")
            }
        }
    }
    
    func clear(userId: String) {
        bg.perform {
            do {
                let req: NSFetchRequest<CDOrder> = CDOrder.fetchRequest()
                req.predicate = NSPredicate(format: "userId == %@", userId)
                let objs = try self.bg.fetch(req)
                objs.forEach { self.bg.delete($0) }
                guard self.bg.hasChanges else { return }
                try self.bg.save()
                print("🧹 CoreDataOrdersStore: cleared orders for uid=\(userId)")
            } catch {
                print("❌ CoreDataOrdersStore.clear error: \(error)")
            }
        }
    }
}
