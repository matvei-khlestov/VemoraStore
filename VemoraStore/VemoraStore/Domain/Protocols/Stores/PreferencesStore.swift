//
//  PreferencesStore.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Foundation

protocol PreferencesStore {
    func set(_ value: String, forKey key: String)
    func string(forKey key: String) -> String?
    func remove(_ key: String)
}
