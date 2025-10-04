//
//  ProfileFRCPublisher.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import CoreData
import Combine

final class ProfileFRCPublisher: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Output
    
    private let subject = CurrentValueSubject<UserProfile?, Never>(nil)
    func publisher() -> AnyPublisher<UserProfile?, Never> { subject.eraseToAnyPublisher() }
    
    // MARK: - FRC
    
    private let frc: NSFetchedResultsController<CDProfile>
    
    // MARK: - Init
    
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
        
        // Если вдруг сюда попадёт не main context, всё равно выполним на его очереди
        context.perform { [weak self] in
            guard let self else { return }
            do {
                try self.frc.performFetch()
                self.subject.send(UserProfile(cd: self.frc.fetchedObjects?.first))
            } catch {
                // В проде лучше пробросить логгер
                self.subject.send(nil)
            }
        }
    }
    
    deinit {
        // Чистим делегата
        frc.delegate = nil
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let objects = controller.fetchedObjects as? [CDProfile]
        subject.send(UserProfile(cd: objects?.first))
    }
}
