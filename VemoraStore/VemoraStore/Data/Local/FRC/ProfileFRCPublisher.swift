//
//  ProfileFRCPublisher.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import CoreData
import Combine

final class ProfileFRCPublisher: NSObject, NSFetchedResultsControllerDelegate {
    private let subject = CurrentValueSubject<UserProfile?, Never>(nil)
    private let frc: NSFetchedResultsController<CDProfile>
    
    init(context: NSManagedObjectContext, userId: String) {
        let req: NSFetchRequest<CDProfile> = CDProfile.fetchRequest()
        req.predicate = NSPredicate(format: "userId == %@", userId)
        req.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        req.fetchLimit = 1
        
        self.frc = NSFetchedResultsController(
            fetchRequest: req,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        frc.delegate = self
        try? frc.performFetch()
        subject.send(UserProfile(cd: frc.fetchedObjects?.first))
    }
    
    func publisher() -> AnyPublisher<UserProfile?, Never> {
        subject.eraseToAnyPublisher()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let objects = controller.fetchedObjects as? [CDProfile]
        subject.send(UserProfile(cd: objects?.first))
    }
}
