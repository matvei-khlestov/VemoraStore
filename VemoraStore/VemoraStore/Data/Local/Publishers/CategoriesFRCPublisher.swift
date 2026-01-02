//
//  CategoriesFRCPublisher.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import CoreData
import Combine

/// Класс `CategoriesFRCPublisher`
///
/// Реализует реактивное наблюдение за локальными данными категорий (`CDCategory`) в Core Data.
///
/// Основные задачи:
/// - выполняет выборку категорий с учётом фильтрации и поискового запроса;
/// - поддерживает обновление данных в реальном времени через `NSFetchedResultsController`;
/// - предоставляет Combine-поток `AnyPublisher<[Category], Never>` для наблюдения за изменениями.
///
/// Используется в:
/// - `CatalogLocalStore` — как источник реактивных обновлений для слоя репозитория.

final class CategoriesFRCPublisher: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Public API
    
    /// Опции конфигурации выборки категорий.
    struct Options: Equatable {
        /// Поисковый запрос для фильтрации по имени.
        var query: String? = nil
        /// Флаг, определяющий, фильтровать ли только активные категории.
        var onlyActive: Bool = true
    }
    
    /// Возвращает Combine-поток, публикующий массив категорий.
    func publisher() -> AnyPublisher<[Category], Never> {
        subject.eraseToAnyPublisher()
    }
    
    // MARK: - Output
    
    /// Паблишер, публикующий актуальное состояние категорий.
    private let subject = CurrentValueSubject<[Category], Never>([])
    
    // MARK: - FRC
    
    /// Контроллер выборки Core Data, отслеживающий изменения в сущностях `CDCategory`.
    private let frc: NSFetchedResultsController<CDCategory>
    
    // MARK: - Designated Init (for testing)
    
    /// Инициализатор с инжектируемым FRC — используется для юнит-тестов.
    /// - Parameter frc: Готовый `NSFetchedResultsController`, предоставленный тестовой средой.
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
    
    // MARK: - Convenience Init (production)
    
    /// Инициализация для продакшн-кода.
    /// - Parameters:
    ///   - context: Контекст Core Data (`viewContext`).
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
    
    /// Устаревший инициализатор, сохранён для обратной совместимости.
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
    
    /// Создаёт запрос выборки категорий на основе переданных опций.
    private static func makeFetchRequest(options: Options) -> NSFetchRequest<CDCategory> {
        let req: NSFetchRequest<CDCategory> = CDCategory.fetchRequest()
        
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
    
    /// Выполняет первичную выборку категорий и публикует результат.
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
    
    /// Делегатный метод, вызываемый при изменении содержимого `NSFetchedResultsController`.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let items = (controller.fetchedObjects as? [CDCategory])?.compactMap(Category.init(cd:)) ?? []
        subject.send(items)
    }
}
