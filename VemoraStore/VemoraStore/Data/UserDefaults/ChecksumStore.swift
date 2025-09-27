//
//  ChecksumStorage.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 26.09.2025.
//

import Foundation

struct ChecksumStorage {
    
    private let ns: String
    private var defaults: UserDefaults { .standard }

    init(namespace: String) {
        self.ns = "com.vemora.store.checksum.\(namespace)"
    }

    func key(_ name: String) -> String { "\(ns).\(name)" }

    func value(for name: String) -> String? {
        defaults.string(forKey: key(name))
    }

    func set(_ value: String?, for name: String) {
        defaults.setValue(value, forKey: key(name))
    }
}
