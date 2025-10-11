//
//  CategoriesFRCPublisher.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import CoreData
import Combine

final class CategoriesFRCPublisher: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Public API
    
    struct Options: Equatable {
        var query: String? = nil
        var onlyActive: Bool = true
    }
    
    func publisher() -> AnyPublisher<[Category], Never> {
        subject.eraseToAnyPublisher()
    }
    
    // MARK: - Output
    
    private let subject = CurrentValueSubject<[Category], Never>([])
    
    // MARK: - FRC
    
    private let frc: NSFetchedResultsController<CDCategory>
    
    // MARK: - Designated init (inject FRC for tests)
    
    /// Позволяет инжектировать готовый FRC для юнит-тестов.
    init(frc: NSFetchedResultsController<CDCategory>) {
        self.frc = frc
        super.init()
        self.frc.delegate = self
        do {
            try self.frc.performFetch()
            let items = (self.frc.fetchedObjects ?? []).compactMap(Category.init(cd:))
            self.subject.send(items)
        } catch {
            print("❌ CategoriesFRC performFetch error:", error)
            self.subject.send([])
        }
    }
    
    // MARK: - Convenience init (prod)
    
    /// - Parameters:
    ///   - context: `viewContext` из NSPersistentContainer
    ///   - options: фильтры и поиск
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
    
    /// Сохранённая форма старого init для обратной совместимости.
    convenience init(
        context: NSManagedObjectContext,
        query: String? = nil,
        onlyActive: Bool = true
    ) {
        self.init(
            context: context,
            options: .init(query: query, onlyActive: onlyActive)
        )
    }
    
    // MARK: - Builders
    
    private static func makeFetchRequest(options: Options) -> NSFetchRequest<CDCategory> {
        let req: NSFetchRequest<CDCategory> = CDCategory.fetchRequest()
        
        // Предикаты
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
        
        // Сортировка: свежие сверху, потом по имени
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
                let items = (self.frc.fetchedObjects ?? []).compactMap(Category.init(cd:))
                self.subject.send(items)
            } catch {
                print("❌ CategoriesFRC fetch error:", error)
                self.subject.send([])
            }
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let items = (controller.fetchedObjects as? [CDCategory])?.compactMap(Category.init(cd:)) ?? []
        subject.send(items)
    }
}
