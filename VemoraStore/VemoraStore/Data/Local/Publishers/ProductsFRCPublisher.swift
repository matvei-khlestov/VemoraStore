//
//  ProductsFRCPublisher.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import CoreData
import Combine

/// Паблишер продуктов на базе `NSFetchedResultsController`.
///
/// Отвечает за:
/// - построение `NSFetchRequest<CDProduct>` с учётом фильтров (`query`, категории, бренды, цены);
/// - первичную выборку и публикацию доменных `Product` через Combine;
/// - автoобновление данных при изменениях в Core Data (делегат FRC).
///
/// Используется в:
/// - `CatalogLocalStore` / `CatalogRepository` как реактивный источник списка товаров.

final class ProductsFRCPublisher: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Output
    
    /// Внутренний сабжект, публикующий актуальный массив `Product`.
    private let subject = CurrentValueSubject<[Product], Never>([])
    
    /// Паблишер списка продуктов для подписчиков UI/вью-моделей.
    func publisher() -> AnyPublisher<[Product], Never> {
        subject.eraseToAnyPublisher()
    }
    
    // MARK: - FRC
    
    /// Контроллер выборки Core Data, отслеживающий сущности `CDProduct`.
    private let frc: NSFetchedResultsController<CDProduct>
    
    // MARK: - Filters (Options)
    
    /// Опции фильтрации/поиска для выборки товаров.
    struct Options: Equatable {
        /// Поисковая строка: ищем по `nameLower` и `keywordsIndex`.
        var query: String?
        /// Ограничение по множеству категорий (по их id).
        var categoryIds: Set<String>?
        /// Ограничение по множеству брендов (по их id).
        var brandIds: Set<String>?
        /// Минимальная цена (включительно).
        var minPrice: Decimal?
        /// Максимальная цена (включительно).
        var maxPrice: Decimal?
        
        /// Удобный инициализатор с параметрами по умолчанию.
        init(
            query: String? = nil,
            categoryIds: Set<String>? = nil,
            brandIds: Set<String>? = nil,
            minPrice: Decimal? = nil,
            maxPrice: Decimal? = nil
        ) {
            self.query = query
            self.categoryIds = categoryIds
            self.brandIds = brandIds
            self.minPrice = minPrice
            self.maxPrice = maxPrice
        }
    }
    
    // MARK: - Designated init (инъекция FRC для тестов)
    
    /// Инициализация с готовым `NSFetchedResultsController` (для unit-тестов).
    init(frc: NSFetchedResultsController<CDProduct>) {
        self.frc = frc
        super.init()
        self.frc.delegate = self
    }
    
    // MARK: - Convenience init (prod)
    
    /// Продакшн-инициализатор: строит `NSFetchRequest` по `options`, создаёт FRC и выполняет первичную выборку.
    convenience init(context: NSManagedObjectContext, options: Options) {
        let request = Self.makeRequest(options: options)
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        self.init(frc: frc)
        performInitialFetch(on: context)
#if DEBUG
        print("ProductsFRCPublisher options: \(options)")
#endif
    }
    
    /// Упрощённый init для обратной совместимости: фильтр по одной категории.
    convenience init(
        context: NSManagedObjectContext,
        query: String?,
        categoryId: String?
    ) {
        self.init(
            context: context,
            options: .init(query: query, categoryIds: categoryId.map { [$0] })
        )
    }
    
    deinit { frc.delegate = nil }
    
    // MARK: - Initial fetch
    
    /// Выполняет первичную выборку и публикует элементы.
    private func performInitialFetch(on context: NSManagedObjectContext) {
        context.perform { [weak self] in
            guard let self else { return }
            do {
                try self.frc.performFetch()
                let items = (self.frc.fetchedObjects ?? []).compactMap(Product.init(cd:))
#if DEBUG
                print("ProductsFRCPublisher initial count=\(items.count)")
#endif
                self.subject.send(items)
            } catch {
#if DEBUG
                print("❌ ProductsFRCPublisher fetch error:", error)
#endif
                self.subject.send([])
            }
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    /// Делегат FRC: пересобирает и публикует массив при изменениях в выборке.
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        let items = (controller.fetchedObjects as? [CDProduct])?.compactMap(Product.init(cd:)) ?? []
#if DEBUG
        print("ProductsFRCPublisher didChange count=\(items.count)")
#endif
        subject.send(items)
    }
}

// MARK: - Request builder

private extension ProductsFRCPublisher {
    
    /// Строит `NSFetchRequest<CDProduct>` с предикатами и сортировкой на основе `Options`.
    static func makeRequest(options: Options) -> NSFetchRequest<CDProduct> {
        let req: NSFetchRequest<CDProduct> = CDProduct.fetchRequest()
        req.fetchBatchSize = 40
        req.returnsObjectsAsFaults = false
        
        // Базовые предикаты: активный товар и активная категория
        var predicates: [NSPredicate] = [
            NSPredicate(format: "isActive == YES"),
            NSPredicate(format: "categoryIsActive == YES")
        ]
        
        // Поиск по имени/ключевым словам
        if let q = options.query?.trimmingCharacters(in: .whitespacesAndNewlines), !q.isEmpty {
            let qLower = q.lowercased()
            let byName = NSPredicate(format: "nameLower CONTAINS[cd] %@", qLower)
            let byKeywords = NSPredicate(format: "keywordsIndex CONTAINS[cd] %@", qLower)
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [byName, byKeywords]))
        }
        
        // Фильтр по категориям
        if let cids = options.categoryIds, !cids.isEmpty {
            predicates.append(NSPredicate(format: "categoryId IN %@", Array(cids)))
        }
        
        // Фильтр по брендам
        if let bids = options.brandIds, !bids.isEmpty {
            predicates.append(NSPredicate(format: "brandId IN %@", Array(bids)))
        }
        
        // Диапазон цен
        if let min = options.minPrice {
            predicates.append(NSPredicate(format: "price >= %f", (min as NSDecimalNumber).doubleValue))
        }
        if let max = options.maxPrice {
            predicates.append(NSPredicate(format: "price <= %f", (max as NSDecimalNumber).doubleValue))
        }
        
        req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        // Сортировка: стабильная, с разбиением по id/категории/бренду
        req.sortDescriptors = [
            NSSortDescriptor(key: "id",         ascending: false),
            NSSortDescriptor(key: "categoryId", ascending: false),
            NSSortDescriptor(key: "brandId",    ascending: false)
        ]
        return req
    }
}
