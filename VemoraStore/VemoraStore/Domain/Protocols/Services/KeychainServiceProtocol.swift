//
//  KeychainServiceProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 02.10.2025.
//

import Foundation

protocol KeychainServiceProtocol: AnyObject {
    // Write
    @discardableResult func set(_ value: String, for key: KeychainKey) -> Bool
    @discardableResult func set(_ value: Data,   for key: KeychainKey) -> Bool
    @discardableResult func set(_ value: Int,    for key: KeychainKey) -> Bool
    @discardableResult func set(_ value: Bool,   for key: KeychainKey) -> Bool
    
    // Read
    func get(_ key: KeychainKey) -> String?
    func data(_ key: KeychainKey) -> Data?
    func int(_ key: KeychainKey) -> Int?
    func bool(_ key: KeychainKey) -> Bool?
    
    // Delete
    @discardableResult func remove(_ key: KeychainKey) -> Bool
    @discardableResult func removeAll() -> Bool
}
