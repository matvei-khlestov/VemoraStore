//
//  KeychainServiceProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 02.10.2025.
//

import Foundation

/// Протокол `KeychainServiceProtocol`
///
/// Определяет интерфейс для безопасного хранения, получения и удаления данных
/// в системном хранилище `Keychain`.
/// Используется для хранения чувствительных данных, таких как токены,
/// идентификаторы пользователей и настройки аутентификации.
///
/// Основные задачи:
/// - безопасная запись строк, чисел, бинарных данных и булевых значений в Keychain;
/// - безопасное чтение данных по ключу с приведением типов;
/// - удаление отдельных записей или полная очистка хранилища.
///
/// Используется в:
/// - `AuthService` для хранения токенов и идентификаторов пользователя;
/// - `SecretsStore` и `SessionManager` для управления авторизацией и настройками безопасности.

protocol KeychainServiceProtocol: AnyObject {
    
    // MARK: - Write
    
    /// Сохраняет строковое значение в Keychain.
    /// - Parameters:
    ///   - value: Строка для сохранения.
    ///   - key: Ключ `KeychainKey`, под которым будет сохранено значение.
    /// - Returns: `true`, если операция выполнена успешно.
    @discardableResult func set(_ value: String, for key: KeychainKey) -> Bool
    
    /// Сохраняет бинарные данные в Keychain.
    /// - Parameters:
    ///   - value: Объект `Data` для сохранения.
    ///   - key: Ключ `KeychainKey`, под которым будет сохранено значение.
    /// - Returns: `true`, если операция выполнена успешно.
    @discardableResult func set(_ value: Data, for key: KeychainKey) -> Bool
    
    /// Сохраняет целое число в Keychain.
    /// - Parameters:
    ///   - value: Целое значение (`Int`).
    ///   - key: Ключ `KeychainKey`.
    /// - Returns: `true`, если операция выполнена успешно.
    @discardableResult func set(_ value: Int, for key: KeychainKey) -> Bool
    
    /// Сохраняет булево значение в Keychain.
    /// - Parameters:
    ///   - value: Логическое значение (`Bool`).
    ///   - key: Ключ `KeychainKey`.
    /// - Returns: `true`, если операция выполнена успешно.
    @discardableResult func set(_ value: Bool, for key: KeychainKey) -> Bool
    
    // MARK: - Read
    
    /// Извлекает строковое значение по указанному ключу.
    /// - Parameter key: Ключ `KeychainKey`.
    /// - Returns: Строка, если значение найдено, иначе `nil`.
    func get(_ key: KeychainKey) -> String?
    
    /// Извлекает бинарные данные по указанному ключу.
    /// - Parameter key: Ключ `KeychainKey`.
    /// - Returns: Объект `Data`, если значение найдено, иначе `nil`.
    func data(_ key: KeychainKey) -> Data?
    
    /// Извлекает целое значение по указанному ключу.
    /// - Parameter key: Ключ `KeychainKey`.
    /// - Returns: Целое число (`Int`), если значение найдено, иначе `nil`.
    func int(_ key: KeychainKey) -> Int?
    
    /// Извлекает булево значение по указанному ключу.
    /// - Parameter key: Ключ `KeychainKey`.
    /// - Returns: Логическое значение (`Bool`), если значение найдено, иначе `nil`.
    func bool(_ key: KeychainKey) -> Bool?
    
    // MARK: - Delete
    
    /// Удаляет значение по указанному ключу.
    /// - Parameter key: Ключ `KeychainKey`.
    /// - Returns: `true`, если удаление прошло успешно.
    @discardableResult func remove(_ key: KeychainKey) -> Bool
    
    /// Полностью очищает все данные из Keychain для текущего приложения.
    /// - Returns: `true`, если очистка выполнена успешно.
    @discardableResult func removeAll() -> Bool
}
