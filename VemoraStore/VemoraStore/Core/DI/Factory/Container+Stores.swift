//
//  Container+Stores.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import FactoryKit
import CoreData

/// Расширение `Container+Stores` — регистрация локальных Core Data-хранилищ в DI-контейнере.
///
/// Назначение:
/// - Связывает слои локального хранения данных с Core Data через DI (`FactoryKit`);
/// - Централизует инициализацию `NSPersistentContainer` и всех store-объектов;
/// - Обеспечивает единое место для управления жизненным циклом локальных стораджей.
///
/// Состав:
/// - `persistentContainer`: singleton-фабрика, возвращающая основной контейнер Core Data (`CoreDataStack.shared.container`);
/// - `profileLocalStore`: локальное хранилище профиля пользователя (`CoreDataProfileStore`);
/// - `catalogLocalStore`: хранилище каталога товаров (`CoreDataCatalogStore`);
/// - `cartLocalStore`: хранилище корзины (`CoreDataCartStore`);
/// - `favoritesLocalStore`: хранилище избранных товаров (`CoreDataFavoritesStore`);
/// - `ordersLocalStore`: хранилище заказов (`CoreDataOrdersStore`).
///
/// Особенности:
/// - Все хранилища (`Store`) объявлены как `.singleton` — один экземпляр на всё приложение;
/// - Все используют общий `NSPersistentContainer`, что обеспечивает консистентность контекста;
/// - Позволяет репозиториям и сервисам работать с локальными данными независимо от слоя представления;
/// - Конфигурация совместима с `FactoryKit`, упрощая внедрение зависимостей.
///
/// Входит в модуль **Dependency Injection (DI)**, обеспечивающий слой Data локальными стораджами Core Data.

extension Container {
    
    var persistentContainer: Factory<NSPersistentContainer> {
        self {
            CoreDataStack.shared.container
        }.singleton
    }
    
    var profileLocalStore: Factory<ProfileLocalStore> {
        self {
            CoreDataProfileStore(container: self.persistentContainer())
        }.singleton
    }
    
    var catalogLocalStore: Factory<CatalogLocalStore> {
        self {
            CoreDataCatalogStore(container: self.persistentContainer())
        }.singleton
    }
    
    var cartLocalStore: Factory<CartLocalStore> {
        self {
            CoreDataCartStore(container: self.persistentContainer())
        }.singleton
    }
    
    var favoritesLocalStore: Factory<FavoritesLocalStore> {
        self {
            CoreDataFavoritesStore(container: self.persistentContainer())
        }.singleton
    }
    
    var ordersLocalStore: Factory<OrdersLocalStore> {
        self {
            CoreDataOrdersStore(container: self.persistentContainer())
        }.singleton
    }
}
