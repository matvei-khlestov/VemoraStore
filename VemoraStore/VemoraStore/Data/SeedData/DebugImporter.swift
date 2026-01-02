//
//  DebugImporter.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 26.09.2025.
//

#if DEBUG
import Foundation
import FirebaseCore
import FirebaseFirestore

// MARK: - Debug Import Orchestrator

final class DebugImporter: DebugImportingProtocol {
    
    private let df = ISO8601DateFormatter()
    
    private let debugImportStorage: DebugImportStoringProtocol
    private let debugImportService: DebugImportServicingProtocol
    
    // MARK: - Init
    
    init(
        debugImportService: DebugImportServicingProtocol,
        debugImportStorage: DebugImportStoringProtocol
    ) {
        self.debugImportService = debugImportService
        self.debugImportStorage = debugImportStorage
    }
    
    // MARK: - Public API
    
    /// Стартап-сценарий: dry-run → импорт (если нужно), выставляет маркеры.
    func runIfNeeded(
        overwrite: Bool = false,
        checksumNamespace: String = SeedConfig.checksumNamespace,
        pruneMissing: Bool = true,
        force: Bool = false
    ) async {
        guard canRun(force: force) else { return }
        
        let t0 = Date()
        
        do {
            let report = try await performDryRun(
                service: debugImportService,
                overwrite: overwrite,
                checksumNamespace: checksumNamespace,
                pruneMissing: pruneMissing
            )
            
            if isNothingToDo(report) {
                markAsSeeded()
                log("ℹ️ [DebugImporter] Изменений нет — запись в Firestore пропущена.")
                return
            }
            
            try await performImport(
                service: debugImportService,
                overwrite: overwrite,
                checksumNamespace: checksumNamespace,
                pruneMissing: pruneMissing,
                startedAt: t0
            )
        } catch {
            log("❌ [DebugImporter] Ошибка импорта: \(error)")
        }
    }
    
    // MARK: - Private helpers
    
    private func canRun(force: Bool) -> Bool {
        guard FirebaseApp.app() != nil else {
            log("⚠️ [DebugImporter] Firebase не сконфигурирован — импорт пропущен")
            return false
        }
        guard SeedConfig.isEnabled else {
            log("ℹ️ [DebugImporter] Импорт выключен (SeedConfig.isEnabled == false)")
            return false
        }
        
        let didSeed = debugImportStorage.didSeed
        let currentVersion = debugImportStorage.seedVersion
        let needsReseed = (currentVersion != SeedConfig.seedVersion)
        
        if !(force || !didSeed || needsReseed) {
            log("ℹ️ [DebugImporter] Импорт уже выполнялся (версия \(currentVersion)) — пропускаем")
            return false
        }
        return true
    }
    
    private func performDryRun(
        service: DebugImportServicingProtocol,
        overwrite: Bool,
        checksumNamespace: String,
        pruneMissing: Bool
    ) async throws -> DryRunReport {
        let (report, _) = try await service.importSmart(
            overwrite: overwrite,
            checksumNamespace: checksumNamespace,
            dryRun: true,
            pruneMissing: pruneMissing
        )
        log("📊 [DebugImporter] Dry-run отчёт:")
        
        let lines = report.summary.components(separatedBy: .newlines)
        let bodyLines = (lines.first?.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("Dry-run:") == true)
        ? Array(lines.dropFirst())
        : lines
        let body = bodyLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        if !body.isEmpty { print(body) }
        
        return report
    }
    
    private func performImport(
        service: DebugImportServicingProtocol,
        overwrite: Bool,
        checksumNamespace: String,
        pruneMissing: Bool,
        startedAt: Date
    ) async throws {
        let (_, outcome) = try await service.importSmart(
            overwrite: overwrite,
            checksumNamespace: checksumNamespace,
            dryRun: false,
            pruneMissing: pruneMissing
        )
        
        markAsSeeded()
        
        let dt = Date().timeIntervalSince(startedAt)
        log("""
        ✅ [DebugImporter] Импорт выполнен за \(String(format: "%.2f", dt))s
        • Brands — upsert: \(outcome.brands), deleted: \(outcome.brandsDeleted)
        • Categories — upsert: \(outcome.categories), deleted: \(outcome.categoriesDeleted)
        • Products — upsert: \(outcome.products), deleted: \(outcome.productsDeleted)
        """)
    }
    
    private func markAsSeeded() {
        debugImportStorage.didSeed = true
        debugImportStorage.seedVersion = SeedConfig.seedVersion
    }
    
    /// Сбросить маркеры — позволит выполнить импорт снова при следующем запуске.
    func resetMarkers() {
        debugImportStorage.resetSeedMarkers()
        log("🔁 [DebugImporter] Маркеры импорта сброшены")
    }
    
    // MARK: - Helpers
    
    /// Проверка, что нечего делать (нет ни добавлений, ни обновлений, ни удалений).
    @inline(__always)
    private func isNothingToDo(_ r: DryRunReport) -> Bool {
        (r.brands.new | r.brands.update | r.brands.delete) == 0 &&
        (r.categories.new | r.categories.update | r.categories.delete) == 0 &&
        (r.products.new | r.products.update | r.products.delete) == 0
    }
    
    /// Единый логер с таймстампом.
    @inline(__always)
    private func log(_ message: String) {
        print("[\(df.string(from: Date()))] \(message)")
    }
}
#endif
