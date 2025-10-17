//
//  DefaultFavoritesRepository.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.10.2025.
//

import Foundation
import Combine

/// Класс `DefaultFavoritesRepository` — реализация репозитория избранного.
///
/// Назначение:
/// - объединяет работу локального (`FavoritesLocalStore`) и удалённого (`FavoritesCollectingProtocol`) источников данных;
/// - синхронизирует список избранных товаров между Firestore и Core Data;
/// - предоставляет реактивное наблюдение за избранным и операции управления.
///
/// Состав:
/// - `remote`: удалённое хранилище Firestore, обеспечивающее CRUD для избранных товаров;
/// - `local`: локальное Core Data-хранилище избранного для офлайн-режима и мгновенного отображения;
/// - `catalog`: локальное хранилище каталога для извлечения метаинформации о товарах;
/// - `userId`: идентификатор текущего пользователя;
/// - `itemsSubject`: Combine-паблишер, транслирующий актуальное состояние избранного.
///
/// Основные функции:
/// - `observeItems()` — наблюдение за всеми элементами избранного пользователя;
/// - `observeIds()` — наблюдение только за идентификаторами избранных товаров;
/// - `refresh(uid:)` — обновление локальных данных из Firestore;
/// - `add(productId:)` — добавление товара в избранное с использованием данных каталога;
/// - `remove(productId:)` — удаление товара из избранного;
/// - `toggle(productId:)` — переключение состояния избранного товара (добавление/удаление);
/// - `clear()` — полная очистка избранного пользователя.
///
/// Особенности реализации:
/// - при изменениях в Firestore (`remote.listen`) локальное хранилище автоматически обновляется;
/// - при работе с избранным используется кеширование через Combine `CurrentValueSubject`;
/// - синхронизация данных реализована реактивно — без ручного обновления UI.

final class DefaultFavoritesRepository: FavoritesRepository {
    
    private let remote: FavoritesCollectingProtocol
    private let local: FavoritesLocalStore
    private let catalog: CatalogLocalStore
    private let userId: String
    
    private var bag = Set<AnyCancellable>()
    private let itemsSubject = CurrentValueSubject<[FavoriteItem], Never>([])
    
    init(remote: FavoritesCollectingProtocol,
         local: FavoritesLocalStore,
         catalog: CatalogLocalStore,
         userId: String) {
        self.remote = remote
        self.local = local
        self.catalog = catalog
        self.userId = userId
        bindStreams()
    }
    
    func observeItems() -> AnyPublisher<[FavoriteItem], Never> {
        itemsSubject.eraseToAnyPublisher()
    }
    
    func observeIds() -> AnyPublisher<Set<String>, Never> {
        observeItems().map { Set($0.map(\.productId)) }.eraseToAnyPublisher()
    }
    
    func refresh(uid: String) async throws {
        let dtos = try await remote.fetch(uid: uid)
        local.replaceAll(userId: userId, with: dtos)
    }
    
    func add(productId: String) async throws {
        guard let meta = catalog.meta(for: productId) else { return }
        let dto = FavoriteDTO(
            userId: userId,
            productId: productId,
            brandName: meta.brandName,
            title: meta.title,
            imageURL: meta.imageURL?.absoluteString,
            updatedAt: Date(),
            price: meta.price
        )
        try await remote.add(uid: userId, dto: dto)
    }
    
    func remove(productId: String) async throws {
        try await remote.remove(uid: userId, productId: productId)
    }
    
    func toggle(productId: String) async throws {
        let ids = Set(itemsSubject.value.map(\.productId))
        if ids.contains(productId) {
            try await remove(productId: productId)
        } else {
            try await add(productId: productId)
        }
    }
    
    func clear() async throws {
        try await remote.clear(uid: userId)
    }
    
    private func bindStreams() {
        local.observeItems(userId: userId)
            .subscribe(itemsSubject)
            .store(in: &bag)
        
        remote.listen(uid: userId)
            .sink { [weak self] dtos in
                guard let self else { return }
                self.local.replaceAll(userId: self.userId, with: dtos)
            }
            .store(in: &bag)
    }
}
