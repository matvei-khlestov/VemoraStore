//
//  FavoritesFRCPublisher.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.10.2025.
//

import CoreData
import Combine

final class FavoritesFRCPublisher: NSObject, NSFetchedResultsControllerDelegate {
    private let subject = CurrentValueSubject<[FavoriteItem], Never>([])
    func publisher() -> AnyPublisher<[FavoriteItem], Never> { subject.eraseToAnyPublisher() }
    
    private let frc: NSFetchedResultsController<CDFavoriteItem>
    
    init(context: NSManagedObjectContext, userId: String) {
        let req: NSFetchRequest<CDFavoriteItem> = CDFavoriteItem.fetchRequest()
        req.predicate = NSPredicate(format: "userId == %@", userId)
        req.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        self.frc = NSFetchedResultsController(fetchRequest: req, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        super.init()
        frc.delegate = self
        context.perform { [weak self] in
            guard let self else { return }
            try? self.frc.performFetch()
            let items = (self.frc.fetchedObjects ?? []).compactMap(FavoriteItem.init(cd:))
            self.subject.send(items)
        }
    }
    
    deinit { frc.delegate = nil }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let objs = controller.fetchedObjects as? [CDFavoriteItem] ?? []
        subject.send(objs.compactMap(FavoriteItem.init(cd:)))
    }
}
