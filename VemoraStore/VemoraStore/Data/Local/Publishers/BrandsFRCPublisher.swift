//
//  BrandsFRCPublisher.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 09.10.2025.
//

import CoreData
import Combine

final class BrandsFRCPublisher: NSObject, NSFetchedResultsControllerDelegate {

    // MARK: - Options

    struct Options {
        var query: String? = nil
        var onlyActive: Bool = true
    }

    // MARK: - Output

    private let subject = CurrentValueSubject<[Brand], Never>([])
    func publisher() -> AnyPublisher<[Brand], Never> { subject.eraseToAnyPublisher() }

    // MARK: - FRC

    private let frc: NSFetchedResultsController<CDBrand>

    // MARK: - Init

    init(context: NSManagedObjectContext, options: Options = .init()) {
        let request = Self.makeFetchRequest(options: options)
        self.frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        self.frc.delegate = self
        performInitialFetch(on: context)
    }

    // MARK: - Builders

    private static func makeFetchRequest(options: Options) -> NSFetchRequest<CDBrand> {
        let req: NSFetchRequest<CDBrand> = CDBrand.fetchRequest()

        var predicates: [NSPredicate] = []
        if options.onlyActive {
            predicates.append(NSPredicate(format: "isActive == YES"))
        }
        if let q = options.query?.trimmingCharacters(in: .whitespacesAndNewlines), !q.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", q))
        }
        if !predicates.isEmpty {
            req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        req.sortDescriptors = [
            NSSortDescriptor(key: "updatedAt", ascending: false),
            NSSortDescriptor(key: "name",      ascending: true)
        ]

        return req
    }

    // MARK: - Fetch

    private func performInitialFetch(on context: NSManagedObjectContext) {
        context.perform { [weak self] in
            guard let self else { return }
            do {
                try self.frc.performFetch()
                let items = (self.frc.fetchedObjects ?? []).compactMap(Brand.init(cd:))
                self.subject.send(items)
            } catch {
                print("❌ BrandsFRC fetch error:", error)
                self.subject.send([])
            }
        }
    }

    // MARK: - NSFetchedResultsControllerDelegate

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let items = (controller.fetchedObjects as? [CDBrand])?.compactMap(Brand.init(cd:)) ?? []
        subject.send(items)
    }
}
