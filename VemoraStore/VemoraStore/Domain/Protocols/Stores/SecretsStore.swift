//
//  SecretsStore.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Foundation

protocol SecretsStore {
    @discardableResult func set(_ value: String, for key: KeychainKey) -> Bool
    func get(_ key: KeychainKey) -> String?
    @discardableResult func remove(_ key: KeychainKey) -> Bool
}
