//
//  BrandsFRCPublisher.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 09.10.2025.
//

import CoreData
import Combine

/// Класс `BrandsFRCPublisher`
///
/// Реализует реактивное наблюдение за локальными данными брендов (`CDBrand`) в Core Data.
///
/// Основные задачи:
/// - выполняет выборку брендов с возможностью фильтрации (поиск, активные бренды);
/// - отслеживает изменения в данных через `NSFetchedResultsController`;
/// - публикует актуальное состояние брендов как Combine-поток `AnyPublisher<[Brand], Never>`.
///
/// Используется в:
/// - `CatalogLocalStore` — как источник реактивных данных для слоя репозитория.

final class BrandsFRCPublisher: NSObject, NSFetchedResultsControllerDelegate {

    // MARK: - Options

    /// Опции конфигурации выборки брендов.
    struct Options {
        /// Поисковый запрос (необязательно).
        var query: String? = nil
        /// Флаг, определяющий, фильтровать ли только активные бренды.
        var onlyActive: Bool = true
    }

    // MARK: - Output

    /// Combine-паблишер, публикующий актуальный список брендов.
    private let subject = CurrentValueSubject<[Brand], Never>([])
    
    /// Возвращает Combine-поток со списком брендов.
    func publisher() -> AnyPublisher<[Brand], Never> {
        subject.eraseToAnyPublisher()
    }

    // MARK: - FRC

    /// Контроллер выборки Core Data, отслеживающий изменения в сущностях `CDBrand`.
    private let frc: NSFetchedResultsController<CDBrand>

    // MARK: - Init

    /// Инициализация `BrandsFRCPublisher`.
    /// - Parameters:
    ///   - context: Контекст Core Data для выполнения выборки.
    ///   - options: Опции фильтрации и поиска.
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

    /// Формирует запрос Core Data с учётом переданных опций фильтрации.
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
            NSSortDescriptor(key: "name", ascending: true)
        ]

        return req
    }

    // MARK: - Fetch

    /// Выполняет начальную выборку брендов и публикует результат.
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

    /// Делегатный метод, вызываемый при изменении данных в `NSFetchedResultsController`.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let items = (controller.fetchedObjects as? [CDBrand])?.compactMap(Brand.init(cd:)) ?? []
        subject.send(items)
    }
}
