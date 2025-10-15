//
//  DefaultsStore.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Foundation

struct DefaultsStore: PreferencesStore {
    private let defaults: UserDefaults
    init(_ defaults: UserDefaults = .standard) { self.defaults = defaults }
    func set(_ value: String, forKey key: String) { defaults.set(value, forKey: key) }
    func string(forKey key: String) -> String? { defaults.string(forKey: key) }
    func remove(_ key: String) { defaults.removeObject(forKey: key) }
}
