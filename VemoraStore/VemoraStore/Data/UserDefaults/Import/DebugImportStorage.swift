//
//  DebugImportStorage.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 26.09.2025.
//

import Foundation

#if DEBUG
/// Обёртка над UserDefaults для работы с флагами сид-данных (Singleton).
final class DebugImportStorage: DebugImportStoringProtocol {
    
    // MARK: - Singleton
    static let shared = DebugImportStorage()
    
    private init() {}
    
    // MARK: - Deps
    
    private var defaults: UserDefaults { .standard }
    
    // MARK: - Keys
    
    private enum Keys {
        static let debugImportEnabled = "com.vemora.store.debugImport.enabled"
        static let didSeed = "com.vemora.store.didSeed"
        static let seedVersion = "com.vemora.store.seedVersion"
        static let overwrite = "com.vemora.store.debugImport.overwrite"
        static let requiredSeedVersion = "com.vemora.store.seedVersion.required"
    }
    
    // MARK: - Properties
    
    var isOverwriteEnabled: Bool {
        get {
            if let v = defaults.object(forKey: Keys.overwrite) as? Bool { return v }
            return false
        }
        set { defaults.set(newValue, forKey: Keys.overwrite) }
    }
    
    var isDebugImportEnabled: Bool {
        get {
            if let v = defaults.object(forKey: Keys.debugImportEnabled) as? Bool { return v }
            return true
        }
        set { defaults.set(newValue, forKey: Keys.debugImportEnabled) }
    }
    
    var didSeed: Bool {
        get { defaults.bool(forKey: Keys.didSeed) }
        set { defaults.set(newValue, forKey: Keys.didSeed) }
    }
    
    /// Проверка, выполнялся ли сид хотя бы один раз
    var didRunOnce: Bool {
        return didSeed || seedVersion != 0
    }
    
    var seedVersion: Int {
        get { defaults.integer(forKey: Keys.seedVersion) }
        set { defaults.set(newValue, forKey: Keys.seedVersion) }
    }
    
    /// Версия сид-данных, которую мы ТРЕБУЕМ сейчас (UI может её менять).
    /// Если не задана — по умолчанию 1.
    var requiredSeedVersion: Int {
        get {
            let v = defaults.integer(forKey: Keys.requiredSeedVersion)
            return v == 0 ? 1 : v
        }
        set {
            defaults.set(newValue, forKey: Keys.requiredSeedVersion)
        }
    }
    
    // MARK: - Reset
    
    func resetSeedMarkers() {
        defaults.removeObject(forKey: Keys.didSeed)
        defaults.removeObject(forKey: Keys.seedVersion)
        defaults.removeObject(forKey: Keys.requiredSeedVersion)
    }
}
#endif
