//
//  CoreDataCatalogStore.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import Foundation
import CoreData
import Combine

/// Локальное хранилище каталога на Core Data.
///
/// Отвечает за:
/// - реактивное наблюдение каталога через FRC-паблишеры:
///   - товары (c фильтрами по поиску, категориям, брендам, ценам);
///   - категории;
///   - бренды;
/// - предоставление live-потока по конкретному товару (`observeProduct(id:)`);
/// - массовый апсерт DTO → Core Data для продуктов, категорий и брендов;
/// - формирование «меты» товара (`meta(for:)`) с O(1) выборкой по `id`.
///
/// Особенности реализации:
/// - чтение/наблюдение работает на `viewContext`, запись — на фоновой `bg` очереди;
/// - два API наблюдения по товарам:
///   - **NEW**: `observeProducts(query:categoryIds:brandIds:minPrice:maxPrice:)` — создаёт отдельный live-stream, ключуется `UUID`;
///   - **legacy**: `observeProducts(query:categoryId:)` — стримы кешируются по составному ключу (поиск+категория);
/// - стримы категорий/брендов лениво создаются и кешируются (один FRC на тип);
/// - live-стримы по товарам автоматически удаляются из кеша по `handleEvents` (completion/cancel);
/// - универсальный апсерт (`genericUpsert`) минимизирует лишние сохранения через сравнение `matches`, вызывает `save()` только при `hasChanges`;
/// - перед сохранением продуктов синхронизируются флаги активности категории в товарах (`categoryIsActive`);
/// - предусмотрены DI-хуки для тестов: фабрики стримов и провайдер `UUID`;
/// - логирование в `#if DEBUG` помогает отслеживать создание/переиспользование стримов и апсерты.

final class CoreDataCatalogStore: BaseCoreDataStore, CatalogLocalStore {
    
    // MARK: - Typealiases (DI)
    
    typealias UUIDProvider = () -> UUID
    
    typealias ProductsStreamFactory = (
        _ context: NSManagedObjectContext,
        _ options: ProductsFRCPublisher.Options
    ) -> ProductsFRCPublisher
    
    typealias CategoriesStreamFactory = (
        _ context: NSManagedObjectContext
    ) -> CategoriesFRCPublisher
    
    typealias BrandsStreamFactory = (
        _ context: NSManagedObjectContext
    ) -> BrandsFRCPublisher
    
    // MARK: - Stream keys (cache only for legacy API)
    
    private struct ProductStreamKey: Hashable {
        let query: String
        let categoryId: String
    }
    
    // MARK: - Streams cache
    
    private var productStreams: [ProductStreamKey: ProductsFRCPublisher] = [:]
    private var categoriesStream: CategoriesFRCPublisher?
    private var brandsStream: BrandsFRCPublisher?
    
    private var liveProductStreams: [UUID: ProductsFRCPublisher] = [:]
    
    // MARK: - DI (with defaults)
    
    private var uuid: UUIDProvider = { UUID() }
    private var makeProductsStream: ProductsStreamFactory = { context, options in
        ProductsFRCPublisher(context: context, options: options)
    }
    private var makeCategoriesStream: CategoriesStreamFactory = { context in
        CategoriesFRCPublisher(context: context)
    }
    private var makeBrandsStream: BrandsStreamFactory = { context in
        BrandsFRCPublisher(context: context)
    }
    
    // MARK: - Testing hooks
    
    #if DEBUG
    func _setUUIDProvider(_ provider: @escaping UUIDProvider) {
        self.uuid = provider
    }
    
    func _setFactories(
        products: ProductsStreamFactory? = nil,
        categories: CategoriesStreamFactory? = nil,
        brands: BrandsStreamFactory? = nil
    ) {
        if let products {
            makeProductsStream = products
        }
        
        if let categories {
            makeCategoriesStream = categories
        }
        
        if let brands {
            makeBrandsStream = brands
        }
    }
    
    func _resetCaches() {
        productStreams.removeAll()
        categoriesStream = nil
        brandsStream = nil
        liveProductStreams.removeAll()
    }
    #endif
    
    // MARK: - Observe (NEW)
    
    func observeProducts(
        query: String?,
        categoryIds: Set<String>?,
        brandIds: Set<String>?,
        minPrice: Decimal?,
        maxPrice: Decimal?
    ) -> AnyPublisher<[Product], Never> {
        
        let key = uuid()
        let options = ProductsFRCPublisher.Options(
            query: query,
            categoryIds: categoryIds,
            brandIds: brandIds,
            minPrice: minPrice,
            maxPrice: maxPrice
        )
        
        let stream = makeProductsStream(viewContext, options)
        liveProductStreams[key] = stream
        
        return stream.publisher()
            .handleEvents(
                receiveCompletion: { [weak self] (_: Subscribers.Completion<Never>) in
                    self?.liveProductStreams[key] = nil
                },
                receiveCancel: { [weak self] in
                    self?.liveProductStreams[key] = nil
                }
            )
            .eraseToAnyPublisher()
    }

    /// Live stream for a single product by id. Built on top of the generic products stream.
    func observeProduct(id: String) -> AnyPublisher<Product?, Never> {
        observeProducts(
            query: nil,
            categoryIds: nil,
            brandIds: nil,
            minPrice: nil,
            maxPrice: nil
        )
        .map { products in products.first(where: { $0.id == id }) }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Observe (legacy)
    
    func observeProducts(query: String?, categoryId: String?) -> AnyPublisher<[Product], Never> {
        let q = (query ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let c = categoryId ?? ""
        let cacheKey = ProductStreamKey(query: q, categoryId: c)
        
        if let cached = productStreams[cacheKey] {
            #if DEBUG
            print("observeProducts() reuse stream key='\(cacheKey.query)|\(cacheKey.categoryId)'")
            #endif
            return cached.publisher()
        }
        
        let options = ProductsFRCPublisher.Options(
            query: q.isEmpty ? nil : q,
            categoryIds: c.isEmpty ? nil : Set([c]),
            brandIds: nil,
            minPrice: nil,
            maxPrice: nil
        )
        let stream = makeProductsStream(viewContext, options)
        productStreams[cacheKey] = stream
        
        #if DEBUG
        print("observeProducts() create stream key='\(cacheKey.query)|\(cacheKey.categoryId)'")
        #endif
        
        return stream.publisher()
    }
    
    func observeCategories() -> AnyPublisher<[Category], Never> {
        if let s = categoriesStream { return s.publisher() }
        let s = makeCategoriesStream(viewContext)
        categoriesStream = s
        #if DEBUG
        print("observeCategories() create stream")
        #endif
        return s.publisher()
    }
    
    func observeBrands() -> AnyPublisher<[Brand], Never> {
        if let s = brandsStream { return s.publisher() }
        let s = makeBrandsStream(viewContext)
        brandsStream = s
        #if DEBUG
        print("observeBrands() create stream")
        #endif
        return s.publisher()
    }
    
    // MARK: - Upsert (public)
    
    func upsertProducts(_ dtos: [ProductDTO]) {
        guard !dtos.isEmpty else { return }
        #if DEBUG
        let sampleIds = dtos.prefix(6).map(\.id).joined(separator: ",")
        print("upsertProducts() start count=\(dtos.count) ids[0..5]='\(sampleIds)'")
        #endif
        
        bg.perform { [weak self] in
            guard let self else { return }
            do {
                try self.genericUpsert(
                    dtos,
                    in: self.bg,
                    fetchRequest: CDProduct.fetchRequest(),
                    dtoID: { $0.id },
                    entityID: { $0.id },
                    setEntityID: { $0.id = $1 },
                    apply: { $0.apply(dto: $1) },
                    matches: { $0.matches($1) },
                    debugName: "upsertProducts",
                    onBeforeSave: { [weak self] in
                        guard let self else { return }
                        try self.syncProductCategoryActiveFlags(in: self.bg, onlyForCategoryIds: nil)
                    }
                )
            } catch {
                print("❌ CoreDataCatalogStore: upsertProducts error: \(error)")
            }
        }
    }
    
    func upsertCategories(_ dtos: [CategoryDTO]) {
        guard !dtos.isEmpty else { return }
        #if DEBUG
        let sampleIds = dtos.prefix(6).map(\.id).joined(separator: ",")
        print("upsertCategories() start count=\(dtos.count) ids[0..5]='\(sampleIds)'")
        #endif
        
        bg.perform { [weak self] in
            guard let self else { return }
            do {
                try self.genericUpsert(
                    dtos,
                    in: self.bg,
                    fetchRequest: CDCategory.fetchRequest(),
                    dtoID: { $0.id },
                    entityID: { $0.id },
                    setEntityID: { $0.id = $1 },
                    apply: { $0.apply(dto: $1) },
                    matches: { $0.matches($1) },
                    debugName: "upsertCategories",
                    onBeforeSave: { [weak self] in
                        guard let self else { return }
                        try self.syncProductCategoryActiveFlags(
                            in: self.bg,
                            onlyForCategoryIds: Set(dtos.map(\.id))
                        )
                    }
                )
            } catch {
                print("❌ CoreDataCatalogStore: upsertCategories error: \(error)")
            }
        }
    }
    
    func upsertBrands(_ dtos: [BrandDTO]) {
        guard !dtos.isEmpty else { return }
        #if DEBUG
        let sampleIds = dtos.prefix(6).map(\.id).joined(separator: ",")
        print("upsertBrands() start count=\(dtos.count) ids[0..5]='\(sampleIds)'")
        #endif
        
        bg.perform { [weak self] in
            guard let self else { return }
            do {
                try self.genericUpsert(
                    dtos,
                    in: self.bg,
                    fetchRequest: CDBrand.fetchRequest(),
                    dtoID: { $0.id },
                    entityID: { $0.id },
                    setEntityID: { $0.id = $1 },
                    apply: { $0.apply(dto: $1) },
                    matches: { $0.matches($1) },
                    debugName: "upsertBrands"
                )
            } catch {
                print("❌ CoreDataCatalogStore: upsertBrands error: \(error)")
            }
        }
    }
}

// MARK: - Meta (CatalogLocalStore)

extension CoreDataCatalogStore {
    /// O(1) fetch по id из viewContext. Потокобезопасно через `performAndWait`.
    public func meta(for productId: String) -> ProductMeta? {
        var result: ProductMeta?
        viewContext.performAndWait {
            let req: NSFetchRequest<CDProduct> = CDProduct.fetchRequest()
            req.predicate = NSPredicate(format: "id == %@", productId)
            req.fetchLimit = 1

            guard
                let cd = try? viewContext.fetch(req).first,
                let name = cd.name
            else {
                result = nil
                return
            }

            let brandName = cd.brandId ?? ""
            let url = cd.imageURL.flatMap(URL.init(string:))
            result = ProductMeta(brandName: brandName, title: name, price: cd.price, imageURL: url)
        }
        return result
    }
}

// MARK: - Generic upsert (reusable & testable)

private extension CoreDataCatalogStore {
    
    struct UpsertStats {
        var inserted = 0
        var updated  = 0
        var skipped  = 0
    }
    
    /// Универсальный апсерт CoreData сущностей по массиву DTO.
    ///
    /// Порядок соответствует прежней логике:
    /// 1) применяем изменения,
    /// 2) выполняем `onBeforeSave` (например, синхронизацию `categoryIsActive`),
    /// 3) сохраняем контекст,
    /// 4) логируем.
    func genericUpsert<Entity: NSManagedObject, DTO>(
        _ dtos: [DTO],
        in context: NSManagedObjectContext,
        fetchRequest: NSFetchRequest<Entity>,
        dtoID: (DTO) -> String,
        entityID: (Entity) -> String?,
        setEntityID: (Entity, String) -> Void,
        apply: (Entity, DTO) -> Void,
        matches: (Entity, DTO) -> Bool,
        debugName: String,
        onBeforeSave: (() throws -> Void)? = nil
    ) throws {
        guard !dtos.isEmpty else { return }
        
        let ids = dtos.map(dtoID)
        fetchRequest.predicate = NSPredicate(format: "id IN %@", ids)
        
        let existing = try context.fetch(fetchRequest)
        let map = Dictionary(uniqueKeysWithValues: existing.compactMap { entity -> (String, Entity)? in
            guard let id = entityID(entity) else { return nil }
            return (id, entity)
        })
        
        var stats = UpsertStats()
        
        for dto in dtos {
            let id = dtoID(dto)
            let entity = map[id] ?? Entity(context: context)
            
            if entityID(entity) == nil {
                setEntityID(entity, id)
                apply(entity, dto)
                stats.inserted += 1
            } else if matches(entity, dto) {
                stats.skipped += 1
            } else {
                apply(entity, dto)
                stats.updated += 1
            }
        }
        
        // Важный шаг: выполняем синхронизации ДО сохранения (как в исходном коде)
        try onBeforeSave?()
        
        guard context.hasChanges else {
            #if DEBUG
            print("\(debugName) done: no changes (inserted=\(stats.inserted), updated=\(stats.updated), skipped=\(stats.skipped))")
            #endif
            return
        }
        
        try context.save()
        #if DEBUG
        print("✅ \(debugName) saved (inserted=\(stats.inserted), updated=\(stats.updated), skipped=\(stats.skipped))")
        #endif
    }
}

// MARK: - Private helpers

private extension CoreDataCatalogStore {
    /// Обновляет `CDProduct.categoryIsActive` на основе `CDCategory.isActive`.
    func syncProductCategoryActiveFlags(
        in context: NSManagedObjectContext,
        onlyForCategoryIds: Set<String>?
    ) throws {
        let catReq: NSFetchRequest<CDCategory> = CDCategory.fetchRequest()
        if let ids = onlyForCategoryIds, !ids.isEmpty {
            catReq.predicate = NSPredicate(format: "id IN %@", ids)
        }
        let categories = try context.fetch(catReq)
        
        let activeMap: [String: Bool] = Dictionary(uniqueKeysWithValues: categories.compactMap { cat in
            guard let id = cat.id else { return nil }
            return (id, cat.isActive)
        })
        guard !activeMap.isEmpty else { return }
        
        let prodReq: NSFetchRequest<CDProduct> = CDProduct.fetchRequest()
        if let ids = onlyForCategoryIds, !ids.isEmpty {
            prodReq.predicate = NSPredicate(format: "categoryId IN %@", ids)
        }
        let products = try context.fetch(prodReq)
        
        for product in products {
            guard let cid = product.categoryId, let catActive = activeMap[cid] else { continue }
            if product.categoryIsActive != catActive {
                product.categoryIsActive = catActive
            }
        }
    }
}
