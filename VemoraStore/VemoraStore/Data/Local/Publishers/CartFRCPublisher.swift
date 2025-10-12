//
//  CartFRCPublisher.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 11.10.2025.
//

import CoreData
import Combine

final class CartFRCPublisher: NSObject, NSFetchedResultsControllerDelegate {
    
    private let subject = CurrentValueSubject<[CartItem], Never>([])
    func publisher() -> AnyPublisher<[CartItem], Never> { subject.eraseToAnyPublisher() }
    
    private let frc: NSFetchedResultsController<CDCartItem>
    
    init(context: NSManagedObjectContext, userId: String) {
        let req: NSFetchRequest<CDCartItem> = CDCartItem.fetchRequest()
        req.predicate = NSPredicate(format: "userId == %@", userId)
        req.sortDescriptors = [
            NSSortDescriptor(key: "productId", ascending: true)
        ]
        
        self.frc = NSFetchedResultsController(
            fetchRequest: req,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        frc.delegate = self
        
        context.perform { [weak self] in
            guard let self else { return }
            do {
                try self.frc.performFetch()
                let items = (self.frc.fetchedObjects ?? []).compactMap { CartItem(cd: $0) }
                self.subject.send(items)
            } catch {
                self.subject.send([])
            }
        }
    }
    
    deinit { frc.delegate = nil }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let objs = controller.fetchedObjects as? [CDCartItem] ?? []
        subject.send(objs.compactMap { CartItem(cd: $0) })
    }
}
