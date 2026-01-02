//
//  KeychainService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 02.10.2025.
//

import Security
import Foundation

/// `KeychainService` — тонкая обёртка над Apple Keychain (Security.framework).
///
/// Назначение
/// - Безопасное хранение чувствительных данных приложения (токены, идентификаторы, флаги).
/// - Единый интерфейс записи/чтения/удаления значений по ключам `KeychainKey`.
///
/// Возможности
/// - Запись: `set(_:for:)` для `String`, `Data`, `Int`, `Bool`.
/// - Чтение: `get(_:)` (`String?`), `data(_:)` (`Data?`), `int(_:)` (`Int?`), `bool(_:)` (`Bool?`).
/// - Удаление: `remove(_:)` (одного значения), `removeAll()` (всех значений сервиса).
/// - Конфигурация: `service` (имя сервиса в кейчейне) и уровень доступности `kSecAttrAccessible*`.
///
/// Особенности реализации
/// - Используется класс записей `kSecClassGenericPassword`, пространство имён ограничено `service`.
/// - Запись реализована с upsert-поведением: при наличии записи — `SecItemUpdate`, иначе — `SecItemAdd`.
/// - `remove`/`removeAll` возвращают `true`, если запись отсутствует (это не считается ошибкой).
/// - Кодировки и преобразования:
///   - `String` ↔︎ `Data` — UTF-8.
///   - `Bool` сериализуется как `"1"`/`"0"` (также читаются `"true"/"false"` в любом регистре).
///   - `Int` хранится как строка (`String`).
/// - Потокобезопасность обеспечивается самим Keychain API; объект не хранит изменяемого состояния.
/// - По умолчанию доступность: `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`
///   (данные доступны после первого разблокирования устройства и **не** синкаются в iCloud).

final class KeychainService: KeychainServiceProtocol {
    
    // MARK: - Config
    
    private let service: String
    private let access: CFString
    
    /// - Parameters:
    ///   - service: имя сервиса в Keychain. По умолчанию — bundle id или "VemoraStore".
    ///   - accessible: уровень доступности (по умолчанию AfterFirstUnlockThisDeviceOnly).
    init(
        service: String = Bundle.main.bundleIdentifier ?? "VemoraStore",
        accessible: CFString = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    ) {
        self.service = service
        self.access = accessible
    }
    
    // MARK: - Public Write
    
    @discardableResult
    func set(_ value: String, for key: KeychainKey) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        return store(data: data, for: key)
    }
    
    @discardableResult
    func set(_ value: Data, for key: KeychainKey) -> Bool {
        store(data: value, for: key)
    }
    
    @discardableResult
    func set(_ value: Int, for key: KeychainKey) -> Bool {
        set(String(value), for: key)
    }
    
    @discardableResult
    func set(_ value: Bool, for key: KeychainKey) -> Bool {
        set(value ? "1" : "0", for: key)
    }
    
    // MARK: - Public Read
    
    func get(_ key: KeychainKey) -> String? {
        guard let data = readData(for: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func data(_ key: KeychainKey) -> Data? {
        readData(for: key)
    }
    
    func int(_ key: KeychainKey) -> Int? {
        guard let s = get(key) else { return nil }
        return Int(s)
    }
    
    func bool(_ key: KeychainKey) -> Bool? {
        guard let s = get(key) else { return nil }
        switch s {
        case "1", "true", "TRUE": return true
        case "0", "false", "FALSE": return false
        default: return nil
        }
    }
    
    // MARK: - Public Delete
    
    @discardableResult
    func remove(_ key: KeychainKey) -> Bool {
        let query = baseQuery(for: key)
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    @discardableResult
    func removeAll() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    // MARK: - Private helpers
    
    private func store(data: Data, for key: KeychainKey) -> Bool {
        let query = baseQuery(for: key)
        
        var exists: CFTypeRef?
        var status = SecItemCopyMatching(query as CFDictionary, &exists)
        
        switch status {
        case errSecSuccess:
            let updateAttrs: [String: Any] = [
                kSecValueData as String: data,
                kSecAttrAccessible as String: access
            ]
            status = SecItemUpdate(query as CFDictionary, updateAttrs as CFDictionary)
            return status == errSecSuccess
            
        case errSecItemNotFound:
            var addAttrs = query
            addAttrs[kSecValueData as String] = data
            addAttrs[kSecAttrAccessible as String] = access
            status = SecItemAdd(addAttrs as CFDictionary, nil)
            return status == errSecSuccess
            
        default:
            return false
        }
    }
    
    private func readData(for key: KeychainKey) -> Data? {
        var query = baseQuery(for: key)
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return data
    }
    
    private func baseQuery(for key: KeychainKey) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]
    }
}
