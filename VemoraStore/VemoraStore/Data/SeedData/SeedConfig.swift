//
//  SeedConfig.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 26.09.2025.
//

import Foundation

// MARK: - Seed Configuration

/// Конфигурация флагов и имён файлов для импорта.
enum SeedConfig {
    /// Можно включать/выключать импорт из UI.
    static var isEnabled: Bool {
        get { DebugImportStorage.shared.isDebugImportEnabled }
        set { DebugImportStorage.shared.isDebugImportEnabled = newValue }
    }
    
    /// Версия сид-данных. Увеличивай при изменении payload'ов.
    static var seedVersion: Int { DebugImportStorage.shared.requiredSeedVersion }
    
    /// Имена JSON-файлов без расширения (лежат в Bundle).
    static let brandsCollection = "brands"
    static let categoriesCollection = "categories"
    static let productsCollection = "products"
    
    /// Расширение файлов.
    static let fileExtension = "json"
    
    /// Namespace для хранимых checksum (можно переключать из UI, если нужно несколько наборов данных).
    static let checksumNamespace = "seed.v1"
}
