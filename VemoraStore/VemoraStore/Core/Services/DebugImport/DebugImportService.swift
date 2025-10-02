//
//  DebugImportService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 26.09.2025.
//

#if DEBUG
import Foundation
import FirebaseCore
import FirebaseFirestore

// MARK: - Import Service

final class DebugImportService: DebugImportServicingProtocol {
    
    // MARK: Dependencies
    
    private let db: Firestore
    private let makeStore: (String) -> ChecksumStoringProtocol
    
    // MARK: Init
    
    init(
        db: Firestore = Firestore.firestore(),
        checksumStoreFactory: @escaping (String) -> ChecksumStoringProtocol
    ) {
        self.db = db
        self.makeStore = checksumStoreFactory
    }
}

// MARK: - High-level Import API

extension DebugImportService {
    /// Выполняет dry-run + импорт с учётом checksum:
    /// - Если файл не изменился (по SHA-256), секция пропускается.
    /// - Можно импортировать только новые (overwrite=false) или обновлять существующие (overwrite=true).
    /// - Повторяет батчи при 429/UNAVAILABLE (экспоненциальный backoff).
    public func importSmart(
        overwrite: Bool = true,
        brandsFile: String = SeedConfig.brandsCollection,
        categoriesFile: String = SeedConfig.categoriesCollection,
        productsFile: String = SeedConfig.productsCollection,
        fileExtension: String = SeedConfig.fileExtension,
        checksumNamespace: String = SeedConfig.checksumNamespace,
        dryRun: Bool = false,
        pruneMissing: Bool = false
    ) async throws -> (report: DryRunReport, outcome: ImportOutcome) {
        try ensureFirestore()
        
        // 1) Подготовка входных данных (JSON + checksum + store)
        let prepared = try prepareInputs(
            brandsFile: brandsFile,
            categoriesFile: categoriesFile,
            productsFile: productsFile,
            ext: fileExtension,
            checksumNamespace: checksumNamespace
        )
        
        // 2) Построение отчёта (dry-run расчёт)
        let report = try await buildReport(
            brands: prepared.brands,
            categories: prepared.categories,
            products: prepared.products
        )
        
        // 3) Режим dry-run — только вернуть отчёт без записи
        if dryRun {
            return (report, ImportOutcome(
                brands: 0, categories: 0, products: 0,
                brandsDeleted: 0, categoriesDeleted: 0, productsDeleted: 0
            ))
        }
        
        // 4) Импорт по секциям
        let outcome = try await importAllSections(
            report: report,
            prepared: prepared,
            overwrite: overwrite,
            pruneMissing: pruneMissing
        )
        
        // 5) Вернуть итог
        return (report, outcome)
    }
}

// MARK: Bundle JSON loader

private extension DebugImportService {
    func load<T: Decodable>(_ name: String, ext: String) throws -> [T] {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            throw ImportError.fileNotFound("\(name).\(ext)")
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            throw ImportError.decodingFailed("\(name).\(ext)", underlying: error)
        }
    }
}

// MARK: - Preparation (JSON + Checksums + Store)

private extension DebugImportService {
    @inline(__always)
    func prepareInputs(
        brandsFile: String,
        categoriesFile: String,
        productsFile: String,
        ext: String,
        checksumNamespace: String
    ) throws -> PreparedInputs {
        let (brands, categories, products) = try loadJSONs(
            brandsFile: brandsFile,
            categoriesFile: categoriesFile,
            productsFile: productsFile,
            ext: ext
        )
        let checksums = try computeChecksums(
            brandsFile: brandsFile,
            categoriesFile: categoriesFile,
            productsFile: productsFile,
            ext: ext
        )
        let store = makeStore(checksumNamespace)
        return PreparedInputs(
            brands: brands,
            categories: categories,
            products: products,
            checksums: checksums,
            store: store
        )
    }
    
    @inline(__always)
    func buildReport(
        brands: [Brand],
        categories: [Category],
        products: [Product]
    ) async throws -> DryRunReport {
        try await dryRunReport(
            brands: brands,
            categories: categories,
            products: products
        )
    }
    
    func loadJSONs(
        brandsFile: String,
        categoriesFile: String,
        productsFile: String,
        ext: String
    ) throws -> (brands: [Brand], categories: [Category], products: [Product]) {
        let brands: [Brand] = try load(brandsFile, ext: ext)
        let categories: [Category] = try load(categoriesFile, ext: ext)
        let products: [Product] = try load(productsFile, ext: ext)
        return (brands, categories, products)
    }
    
    func computeChecksums(
        brandsFile: String,
        categoriesFile: String,
        productsFile: String,
        ext: String
    ) throws -> [String: String] {
        try bundleChecksums([
            (key: SeedConfig.brandsCollection, file: brandsFile, ext: ext),
            (key: SeedConfig.categoriesCollection, file: categoriesFile, ext: ext),
            (key: SeedConfig.productsCollection, file: productsFile, ext: ext)
        ])
    }
}

// MARK: - Section Planning & Execution

private extension DebugImportService {
    typealias Operation = () async throws -> SectionWriteResult
    
    struct SectionPlan {
        let section: DryRunReport.Section
        let checksumKey: String
        let op: Operation
        let apply: (inout ImportOutcome, SectionWriteResult) -> Void
    }
    
    @inline(__always)
    func makeSectionPlans(
        report: DryRunReport,
        prepared: PreparedInputs,
        overwrite: Bool,
        pruneMissing: Bool
    ) -> [SectionPlan] {
        [
            SectionPlan(
                section: report.brands,
                checksumKey: SeedConfig.brandsCollection,
                op: { [prepared, overwrite, pruneMissing] in
                    try await self.processBrands(
                        brands: prepared.brands,
                        overwrite: overwrite,
                        pruneMissing: pruneMissing,
                        jsonIDs: Set(prepared.brands.map { $0.id })
                    )
                },
                apply: { outcome, res in
                    outcome = outcome.updating(
                        brands: res.upserted,
                        brandsDeleted: res.deleted
                    )
                }
            ),
            SectionPlan(
                section: report.categories,
                checksumKey: SeedConfig.categoriesCollection,
                op: { [prepared, overwrite, pruneMissing] in
                    try await self.processCategories(
                        categories: prepared.categories,
                        overwrite: overwrite,
                        pruneMissing: pruneMissing,
                        jsonIDs: Set(prepared.categories.map { $0.id })
                    )
                },
                apply: { outcome, res in
                    outcome = outcome.updating(
                        categories: res.upserted,
                        categoriesDeleted: res.deleted
                    )
                }
            ),
            SectionPlan(
                section: report.products,
                checksumKey: SeedConfig.productsCollection,
                op: { [prepared, overwrite, pruneMissing] in
                    try await self.processProducts(
                        products: prepared.products,
                        overwrite: overwrite,
                        pruneMissing: pruneMissing,
                        jsonIDs: Set(prepared.products.map { $0.id })
                    )
                },
                apply: { outcome, res in
                    outcome = outcome.updating(
                        products: res.upserted,
                        productsDeleted: res.deleted
                    )
                }
            )
        ]
    }
    
    @inline(__always)
    func importAllSections(
        report: DryRunReport,
        prepared: PreparedInputs,
        overwrite: Bool,
        pruneMissing: Bool
    ) async throws -> ImportOutcome {
        var outcome = ImportOutcome(
            brands: 0, categories: 0, products: 0,
            brandsDeleted: 0, categoriesDeleted: 0, productsDeleted: 0
        )
        
        let plans = makeSectionPlans(
            report: report,
            prepared: prepared,
            overwrite: overwrite,
            pruneMissing: pruneMissing
        )
        
        for plan in plans {
            if let res = try await runSection(
                section: plan.section,
                checksumKey: plan.checksumKey,
                store: prepared.store,
                checksums: prepared.checksums,
                pruneMissing: pruneMissing,
                operation: plan.op
            ) {
                plan.apply(&outcome, res)
            }
        }
        
        return outcome
    }
    
    @inline(__always)
    func runSection(
        section: DryRunReport.Section,
        checksumKey: String,
        store: ChecksumStoringProtocol,
        checksums: [String: String],
        pruneMissing: Bool,
        operation: () async throws -> SectionWriteResult
    ) async throws -> SectionWriteResult? {
        let changedByChecksum = store.value(for: checksumKey) != checksums[checksumKey]
        let mustImport = shouldImportSection(
            changedByChecksum: changedByChecksum,
            section: section,
            pruneMissing: pruneMissing
        )
        guard mustImport else { return nil }
        let res = try await operation()
        if res.didWrite { store.set(checksums[checksumKey], for: checksumKey) }
        return res
    }
}

// MARK: - Section Operations (Brands / Categories / Products)

private extension DebugImportService {
    func processBrands(
        brands: [Brand],
        overwrite: Bool,
        pruneMissing: Bool,
        jsonIDs: Set<String>
    ) async throws -> SectionWriteResult {
        var upserted = 0, deleted = 0
        
        if pruneMissing {
            let refs = try await deletionsFor(collection: SeedConfig.brandsCollection, jsonIDs: jsonIDs)
            if !refs.isEmpty {
                try await deleteBatchWithRetry(refs: refs)
                deleted = refs.count
            }
        }
        
        if !brands.isEmpty {
            upserted = try await upsertWithTimestampsAndRetry(
                collection: SeedConfig.brandsCollection,
                models: brands,
                overwrite: overwrite,
                map: { b in ["name": b.name, "imageURL": b.imageURL, "isActive": b.isActive] }
            )
        }
        
        return SectionWriteResult(upserted: upserted, deleted: deleted)
    }
    
    func processCategories(
        categories: [Category],
        overwrite: Bool,
        pruneMissing: Bool,
        jsonIDs: Set<String>
    ) async throws -> SectionWriteResult {
        var upserted = 0, deleted = 0
        
        if pruneMissing {
            let refs = try await deletionsFor(collection: SeedConfig.categoriesCollection, jsonIDs: jsonIDs)
            if !refs.isEmpty {
                try await deleteBatchWithRetry(refs: refs)
                deleted = refs.count
            }
        }
        
        if !categories.isEmpty {
            upserted = try await upsertWithTimestampsAndRetry(
                collection: SeedConfig.categoriesCollection,
                models: categories,
                overwrite: overwrite,
                map: { c in [
                    "name": c.name,
                    "imageURL": c.imageURL,
                    "brandIds": c.brandIds,
                    "isActive": c.isActive
                ] }
            )
        }
        
        return SectionWriteResult(upserted: upserted, deleted: deleted)
    }
    
    func processProducts(
        products: [Product],
        overwrite: Bool,
        pruneMissing: Bool,
        jsonIDs: Set<String>
    ) async throws -> SectionWriteResult {
        var upserted = 0, deleted = 0
        
        if pruneMissing {
            let refs = try await deletionsFor(collection: SeedConfig.productsCollection, jsonIDs: jsonIDs)
            if !refs.isEmpty {
                try await deleteBatchWithRetry(refs: refs)
                deleted = refs.count
            }
        }
        
        if !products.isEmpty {
            upserted = try await upsertWithTimestampsAndRetry(
                collection: SeedConfig.productsCollection,
                models: products,
                overwrite: overwrite,
                map: { p in
                    [
                        "name": p.name,
                        "description": p.description,
                        "nameLower": p.nameLower,
                        "categoryId": p.categoryId,
                        "brandId": p.brandId,
                        "price": p.price,
                        "imageURL": p.imageURL,
                        "isActive": p.isActive,
                        "keywords": p.keywords
                    ]
                }
            )
        }
        
        return SectionWriteResult(upserted: upserted, deleted: deleted)
    }
}

// MARK: - Firestore Preconditions

private extension DebugImportService {
    @inline(__always)
    func ensureFirestore() throws {
        guard FirebaseApp.app() != nil else { throw ImportError.firestoreNotConfigured }
    }
}

// MARK: - Dry-run Builders

private extension DebugImportService {
    typealias Doc = [String: Any]
    
    @inline(__always)
    func buildBrandsSection(_ brands: [Brand]) async throws -> DryRunReport.Section {
        try await computeSection(
            name: "brands",
            collection: SeedConfig.brandsCollection,
            models: brands,
            id: \.id,
            map: { ["name": $0.name, "imageURL": $0.imageURL, "isActive": $0.isActive] },
            compareKeys: ["name", "imageURL", "isActive"]
        )
    }
    
    @inline(__always)
    func buildCategoriesSection(_ categories: [Category]) async throws -> DryRunReport.Section {
        try await computeSection(
            name: "categories",
            collection: SeedConfig.categoriesCollection,
            models: categories,
            id: \.id,
            map: { ["name": $0.name, "imageURL": $0.imageURL, "brandIds": $0.brandIds, "isActive": $0.isActive] },
            compareKeys: ["name", "imageURL", "brandIds", "isActive"]
        )
    }
    
    @inline(__always)
    func buildProductsSection(_ products: [Product]) async throws -> DryRunReport.Section {
        try await computeSection(
            name: "products",
            collection: SeedConfig.productsCollection,
            models: products,
            id: \.id,
            map: {
                [
                    "name":        $0.name,
                    "description": $0.description,
                    "nameLower":   $0.nameLower,
                    "categoryId":  $0.categoryId,
                    "brandId":     $0.brandId,
                    "price":       $0.price,
                    "imageURL":    $0.imageURL,
                    "isActive":    $0.isActive,
                    "keywords":    $0.keywords
                ]
            },
            compareKeys: [
                "name",
                "description",
                "nameLower",
                "categoryId",
                "brandId",
                "price",
                "imageURL",
                "isActive",
                "keywords"
            ]
        )
    }
    
    func dryRunReport(
        brands: [Brand],
        categories: [Category],
        products: [Product]
    ) async throws -> DryRunReport {
        let brandsSection = try await buildBrandsSection(brands)
        let categoriesSection = try await buildCategoriesSection(categories)
        let productsSection = try await buildProductsSection(products)
        return DryRunReport(
            brands: brandsSection,
            categories: categoriesSection,
            products: productsSection
        )
    }
    
    func fetchExistingDocuments(collection: String,
                                ids: [String]) async throws -> [String: [String: Any]] {
        var result: [String: [String: Any]] = [:]
        
        try await withThrowingTaskGroup(of: (String, [String: Any]?).self) { group in
            for id in ids {
                group.addTask { [db] in
                    let snap = try await db.collection(collection).document(id).getDocument()
                    let data = snap.data()
                    return (id, data)
                }
            }
            for try await (id, data) in group {
                if let data { result[id] = data }
            }
        }
        return result
    }
    
    func computeSection<T>(
        name: String,
        collection: String,
        models: [T],
        id: KeyPath<T, String>,
        map: (T) -> Doc,
        compareKeys: [String]
    ) async throws -> DryRunReport.Section {
        
        let jsonIDs = Set(models.map { $0[keyPath: id] })
        async let existingForJSONTask = fetchExistingDocuments(collection: collection, ids: Array(jsonIDs))
        async let allExistingIDsTask   = fetchAllIDs(in: collection)
        
        let (existingForJSON, allExistingIDs) = try await (existingForJSONTask, allExistingIDsTask)
        let deletions = allExistingIDs.subtracting(jsonIDs)
        
        var create = 0, update = 0, skip = 0
        for m in models {
            let mid  = m[keyPath: id]
            let data = map(m)
            if let old = existingForJSON[mid] {
                equalByKeys(old, data, keys: compareKeys) ? (skip += 1) : (update += 1)
            } else {
                create += 1
            }
        }
        
        return .init(
            name: name,
            willCreate: create,
            willUpdate: update,
            willSkip:   skip,
            willDelete: deletions.count,
            totalJSON:  models.count
        )
    }
    
    @inline(__always)
    func pick(_ dict: Doc, keys: [String]) -> Doc {
        var out: Doc = [:]
        for k in keys { if let v = dict[k] { out[k] = v } }
        return out
    }
    
    @inline(__always)
    func canonicalJSON(_ dict: Doc) -> String {
        let data = (try? JSONSerialization.data(withJSONObject: dict, options: [.sortedKeys])) ?? Data()
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    @inline(__always)
    func equalByKeys(_ lhs: Doc, _ rhs: Doc, keys: [String]) -> Bool {
        canonicalJSON(pick(lhs, keys: keys)) == canonicalJSON(pick(rhs, keys: keys))
    }
}

// MARK: - Import Decision

private extension DebugImportService {
    @inline(__always)
    func shouldImportSection(
        changedByChecksum: Bool,
        section: DryRunReport.Section,
        pruneMissing: Bool
    ) -> Bool {
        changedByChecksum
        || section.willCreate > 0
        || section.willUpdate > 0
        || (pruneMissing && section.willDelete > 0)
    }
}

// MARK: - Upsert with Retry / Backoff

private extension DebugImportService {
    /// Upsert с корректной логикой createdAt/updatedAt и учётом флага overwrite.
    /// - createdAt: пишем только если документа ещё нет (serverTimestamp)
    /// - updatedAt: всегда FieldValue.serverTimestamp()
    /// - overwrite == false: существующие документы пропускаем (создаём только новые)
    func upsertWithTimestampsAndRetry<T>(
        collection: String,
        models: [T],
        overwrite: Bool,
        map: (T) -> [String: Any]
    ) async throws -> Int {
        
        // Разбиваем на чанки
        let chunkSize = 300
        var total = 0
        
        for chunkStart in stride(from: 0, to: models.count, by: chunkSize) {
            let end = min(chunkStart + chunkSize, models.count)
            let slice = Array(models[chunkStart..<end])
            
            // Готовим операции set/merge
            var prepared: [(ref: DocumentReference, data: [String: Any], isNew: Bool)] = []
            prepared.reserveCapacity(slice.count)
            
            for model in slice {
                let id: String
                switch model {
                case let b as Brand: id = b.id
                case let c as Category: id = c.id
                case let p as Product: id = p.id
                default: continue
                }
                let ref = db.collection(collection).document(id)
                let snap = try await ref.getDocument()
                
                let isNew = !snap.exists
                if !isNew && !overwrite { continue }
                
                var data = map(model)
                data["updatedAt"] = FieldValue.serverTimestamp()
                if isNew { data["createdAt"] = FieldValue.serverTimestamp() }
                prepared.append((ref, data, isNew))
            }
            
            guard !prepared.isEmpty else { continue }
            
            // Коммит с retry/backoff
            try await commitBatchWithRetry(operations: prepared)
            total += prepared.count
        }
        return total
    }
    
    func commitBatchWithRetry(
        operations: [(ref: DocumentReference, data: [String: Any], isNew: Bool)],
        maxAttempts: Int = 5,
        initialDelay: TimeInterval = 0.25,
        jitter: ClosedRange<Double> = 0.0...0.25
    ) async throws {
        var attempt = 0
        var delay = initialDelay
        
        while true {
            do {
                let batch = db.batch()
                for op in operations {
                    if op.isNew {
                        batch.setData(op.data, forDocument: op.ref, merge: false)
                    } else {
                        batch.setData(op.data, forDocument: op.ref, merge: true)
                    }
                }
                try await batch.commit()
                return
            } catch {
                attempt += 1
                if attempt >= maxAttempts || !isRetryable(error) {
                    throw error
                }
                // backoff + джиттер
                let jitterSec = Double.random(in: jitter)
                try await Task.sleep(nanoseconds: UInt64((delay + jitterSec) * 1_000_000_000))
                delay *= 2
            }
        }
    }
    
    func isRetryable(_ error: Error) -> Bool {
        let ns = error as NSError
        
        if ns.domain == FirestoreErrorDomain {
            switch ns.code {
            case FirestoreErrorCode.unavailable.rawValue,
                FirestoreErrorCode.deadlineExceeded.rawValue,
                FirestoreErrorCode.resourceExhausted.rawValue:
                return true
            default:
                return false
            }
        }
        // сетевые ошибки тоже можно попробовать ретраить
        let isNet = (ns.domain == NSURLErrorDomain)
        return isNet
    }
}

// MARK: - Checksums

private extension DebugImportService {
    func bundleChecksums(_ files: [(key: String, file: String, ext: String)]) throws -> [String: String] {
        var dict: [String: String] = [:]
        for f in files {
            guard let url = Bundle.main.url(forResource: f.file, withExtension: f.ext) else {
                throw ImportError.fileNotFound("\(f.file).\(f.ext)")
            }
            let data = try Data(contentsOf: url)
            dict[f.key] = SHA256.hex(of: data)
        }
        return dict
    }
}

// MARK: - Deletions

private extension DebugImportService {
    func fetchAllIDs(in collection: String) async throws -> Set<String> {
        var ids = Set<String>()
        let snapshot = try await db.collection(collection).getDocuments()
        for doc in snapshot.documents { ids.insert(doc.documentID) }
        return ids
    }
    
    func deletionsFor(collection: String, jsonIDs: Set<String>) async throws -> [DocumentReference] {
        let existing = try await fetchAllIDs(in: collection)
        let toDelete = existing.subtracting(jsonIDs)
        return toDelete.map { db.collection(collection).document($0) }
    }
    
    func deleteBatchWithRetry(
        refs: [DocumentReference],
        maxAttempts: Int = 5,
        initialDelay: TimeInterval = 0.25,
        jitter: ClosedRange<Double> = 0.0...0.25
    ) async throws {
        var attempt = 0
        var delay = initialDelay
        while true {
            do {
                let batch = db.batch()
                for ref in refs { batch.deleteDocument(ref) }
                try await batch.commit()
                return
            } catch {
                attempt += 1
                if attempt >= maxAttempts || !isRetryable(error) { throw error }
                let jitterSec = Double.random(in: jitter)
                try await Task.sleep(nanoseconds: UInt64((delay + jitterSec) * 1_000_000_000))
                delay *= 2
            }
        }
    }
}
#endif

