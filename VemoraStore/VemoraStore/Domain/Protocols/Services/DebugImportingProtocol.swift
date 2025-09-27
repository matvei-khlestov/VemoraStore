//
//  DebugImportingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 27.09.2025.
//

import Foundation

#if DEBUG
/// Контракт оркестратора импорта (для DI/тестов)
protocol DebugImportingProtocol: AnyObject {
    /// Запуск пайплайна (dry-run → импорт)
    func runIfNeeded(
        overwrite: Bool,
        checksumNamespace: String,
        pruneMissing: Bool,
        force: Bool
    ) async
    
    /// Сброс маркеров импорта
    func resetMarkers()
}

// Удобный враппер с дефолтными параметрами
extension DebugImportingProtocol {
    @inlinable
    func runIfNeeded(
        overwrite: Bool = false,
        checksumNamespace: String = SeedConfig.checksumNamespace,
        pruneMissing: Bool = true,
        force: Bool = false
    ) async {
        await runIfNeeded(
            overwrite: overwrite,
            checksumNamespace: checksumNamespace,
            pruneMissing: pruneMissing,
            force: force
        )
    }
}
#endif
