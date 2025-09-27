//
//  DebugImportServicingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 27.09.2025.
//

import Foundation

#if DEBUG
protocol DebugImportServicingProtocol: AnyObject {
    func importSmart(
        overwrite: Bool,
        brandsFile: String,
        categoriesFile: String,
        productsFile: String,
        fileExtension: String,
        checksumNamespace: String,
        dryRun: Bool,
        pruneMissing: Bool
    ) async throws -> (report: DryRunReport, outcome: ImportOutcome)
}

extension DebugImportServicingProtocol {
    /// Convenience overload with sensible defaults for bundle file names and extension.
    func importSmart(
        overwrite: Bool,
        checksumNamespace: String,
        dryRun: Bool,
        pruneMissing: Bool
    ) async throws -> (report: DryRunReport, outcome: ImportOutcome) {
        try await importSmart(
            overwrite: overwrite,
            brandsFile: SeedConfig.brandsCollection,
            categoriesFile: SeedConfig.categoriesCollection,
            productsFile: SeedConfig.productsCollection,
            fileExtension: SeedConfig.fileExtension,
            checksumNamespace: checksumNamespace,
            dryRun: dryRun,
            pruneMissing: pruneMissing
        )
    }
}
#endif
