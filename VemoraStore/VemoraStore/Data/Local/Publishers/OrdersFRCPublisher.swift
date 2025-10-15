//
//  OrdersFRCPublisher.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Foundation
import CoreData
import Combine

final class OrdersFRCPublisher: NSObject, NSFetchedResultsControllerDelegate {

    private let subject = CurrentValueSubject<[OrderEntity], Never>([])
    func publisher() -> AnyPublisher<[OrderEntity], Never> { subject.eraseToAnyPublisher() }

    private let frc: NSFetchedResultsController<CDOrder>

    init(context: NSManagedObjectContext, userId: String) {
        let req: NSFetchRequest<CDOrder> = CDOrder.fetchRequest()
        req.predicate = NSPredicate(format: "userId == %@", userId)
        req.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
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
                let entities = (self.frc.fetchedObjects ?? []).compactMap { OrderEntity(cd: $0) }
                self.subject.send(entities)
            } catch {
                self.subject.send([])
            }
        }
    }

    deinit { frc.delegate = nil }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let objs = controller.fetchedObjects as? [CDOrder] ?? []
        subject.send(objs.compactMap { OrderEntity(cd: $0) })
    }
}
