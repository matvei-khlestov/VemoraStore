//
//  ChecksumStorage.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 26.09.2025.
//

import Foundation

#if DEBUG
// MARK: - Impl

final class ChecksumStorage: ChecksumStoringProtocol {
    
    // MARK: - Properties
    
    private let ns: String
    private var defaults: UserDefaults { .standard }
    
    // MARK: - Init
    
    init(namespace: String) {
        self.ns = "com.vemora.store.checksum.\(namespace)"
    }
    
    // MARK: - Helpers
    
    private func key(_ name: String) -> String { "\(ns).\(name)" }
    
    // MARK: - ChecksumStoring
    
    func value(for name: String) -> String? {
        defaults.string(forKey: key(name))
    }
    
    func set(_ value: String?, for name: String) {
        defaults.setValue(value, forKey: key(name))
    }
}
#endif
