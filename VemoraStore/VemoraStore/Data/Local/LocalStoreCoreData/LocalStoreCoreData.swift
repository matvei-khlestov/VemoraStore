//
//  LocalStoreCoreData.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import CoreData
import Combine

final class LocalStoreCoreData: LocalStore {
    private let container: NSPersistentContainer
    private let bg: NSManagedObjectContext

    init(container: NSPersistentContainer) {
        self.container = container
        self.bg = container.newBackgroundContext()
        self.bg.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func observeProfile(userId: String) -> AnyPublisher<UserProfile?, Never> {
        ProfileFRCPublisher(context: container.viewContext, userId: userId).publisher()
    }

    func upsertProfile(_ dto: ProfileDTO) {
        bg.perform {
            let req: NSFetchRequest<CDProfile> = CDProfile.fetchRequest()
            req.predicate = NSPredicate(format: "userId == %@", dto.userId)
            req.fetchLimit = 1

            let entity = (try? self.bg.fetch(req).first) ?? CDProfile(context: self.bg)
            entity.apply(dto: dto)

            try? self.bg.save()
        }
    }
}
