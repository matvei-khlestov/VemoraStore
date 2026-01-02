//
//  FavoritesCollectingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.10.2025.
//

import Combine

/// Протокол `FavoritesCollectingProtocol`
///
/// Определяет интерфейс для работы с коллекцией **избранных товаров** пользователя.
///
/// Основные задачи:
/// - загрузка списка избранных товаров (`fetch`);
/// - добавление и удаление элементов (`add`, `remove`);
/// - очистка избранного (`clear`);
/// - реактивное получение актуального состояния (`listen`).
///
/// Используется в:
/// - `FavoritesRepository` для синхронизации данных между сервером и локальным хранилищем;
/// - `FavoritesViewModel` для отображения и управления избранными товарами в UI.

protocol FavoritesCollectingProtocol: AnyObject {
    
    /// Загружает список избранных товаров пользователя.
    /// - Parameter uid: Идентификатор пользователя.
    /// - Returns: Массив моделей `FavoriteDTO`.
    func fetch(uid: String) async throws -> [FavoriteDTO]
    
    /// Добавляет товар в избранное.
    /// - Parameters:
    ///   - uid: Идентификатор пользователя.
    ///   - dto: DTO добавляемого избранного товара.
    func add(uid: String, dto: FavoriteDTO) async throws
    
    /// Удаляет товар из избранного.
    /// - Parameters:
    ///   - uid: Идентификатор пользователя.
    ///   - productId: Идентификатор товара.
    func remove(uid: String, productId: String) async throws
    
    /// Полностью очищает список избранных товаров пользователя.
    /// - Parameter uid: Идентификатор пользователя.
    func clear(uid: String) async throws
    
    /// Реактивно слушает изменения в коллекции избранного.
    /// - Parameter uid: Идентификатор пользователя.
    /// - Returns: Паблишер, эмитирующий актуальный список `FavoriteDTO`.
    func listen(uid: String) -> AnyPublisher<[FavoriteDTO], Never>
}
