//
//  FavoritesRepository.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.10.2025.
//

import Combine

/// Протокол `FavoritesRepository`
///
/// Определяет единый интерфейс для работы с избранными товарами пользователя,
/// объединяя локальные (`FavoritesLocalStore`) и удалённые (`FavoritesCollectingProtocol`)
/// источники данных.
///
/// Основные задачи:
/// - предоставление реактивных обновлений избранных товаров (`observeItems`, `observeIds`);
/// - синхронизация локального состояния с удалённым (`refresh`);
/// - добавление, удаление и переключение состояния избранного (`add`, `remove`, `toggle`);
/// - очистка локального хранилища при выходе пользователя (`clear`).
///
/// Используется в:
/// - `FavoritesViewModel` для отображения списка избранных товаров;
/// - `ProductDetailsViewModel` и `CatalogViewModel` для обновления состояния «в избранном»;
/// - `CartViewModel` — для синхронизации избранного с корзиной при взаимодействии пользователя.
///
/// Репозиторий инкапсулирует бизнес-логику обновления состояния и управляет
/// асинхронными источниками данных через Combine и async/await.

protocol FavoritesRepository: AnyObject {
    
    // MARK: - Streams
    
    /// Наблюдает за всеми избранными товарами пользователя.
    /// - Returns: Паблишер, эмитирующий массив `FavoriteItem`.
    func observeItems() -> AnyPublisher<[FavoriteItem], Never>
    
    /// Наблюдает за идентификаторами избранных товаров.
    /// - Returns: Паблишер, эмитирующий множество `Set<String>` (ID товаров).
    func observeIds() -> AnyPublisher<Set<String>, Never>

    // MARK: - Commands
    
    /// Обновляет локальное состояние, синхронизируя избранное с сервером.
    /// - Parameter uid: Идентификатор пользователя.
    func refresh(uid: String) async throws
    
    /// Добавляет товар в избранное.
    /// - Parameter productId: Идентификатор товара.
    func add(productId: String) async throws
    
    /// Удаляет товар из избранного.
    /// - Parameter productId: Идентификатор товара.
    func remove(productId: String) async throws
    
    /// Переключает состояние избранного (добавляет или удаляет).
    /// - Parameter productId: Идентификатор товара.
    func toggle(productId: String) async throws
    
    /// Полностью очищает избранное (например, при выходе пользователя).
    func clear() async throws
}
