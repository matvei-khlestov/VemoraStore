//
//  FavoritesLocalStore.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.10.2025.
//

import Combine
import CoreData

/// Протокол `FavoritesLocalStore`
///
/// Определяет контракт для **локального хранения избранных товаров** пользователя.
///
/// Основные задачи:
/// - реактивное наблюдение за избранными товарами (`observeItems`);
/// - синхронизация локальных данных с удалёнными (`replaceAll`, `upsert`);
/// - удаление товаров (`remove`);
/// - очистка избранного (`clear`).
///
/// Используется в:
/// - `FavoritesRepository` для объединения локальных и удалённых источников данных;

protocol FavoritesLocalStore: AnyObject {
    
    /// Наблюдает за изменениями списка избранных товаров пользователя.
    /// - Parameter userId: Идентификатор пользователя.
    /// - Returns: Паблишер, который эмитирует массив `FavoriteItem` при изменениях.
    func observeItems(userId: String) -> AnyPublisher<[FavoriteItem], Never>
    
    /// Полностью заменяет локальные данные избранного новыми DTO.
    /// - Parameters:
    ///   - userId: Идентификатор пользователя.
    ///   - dtos: Новый список DTO избранных товаров.
    func replaceAll(userId: String, with dtos: [FavoriteDTO])
    
    /// Добавляет или обновляет товар в локальном избранном.
    /// - Parameters:
    ///   - userId: Идентификатор пользователя.
    ///   - dto: DTO товара для вставки или обновления.
    func upsert(userId: String, dto: FavoriteDTO)
    
    /// Удаляет товар из локального избранного по идентификатору продукта.
    /// - Parameters:
    ///   - userId: Идентификатор пользователя.
    ///   - productId: Идентификатор удаляемого товара.
    func remove(userId: String, productId: String)
    
    /// Полностью очищает локальное избранное пользователя.
    /// - Parameter userId: Идентификатор пользователя.
    func clear(userId: String)
}

