//
//  Container+Collections.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 02.10.2025.
//

import Foundation
import FactoryKit

/// Расширение `Container+Collections` — регистрация удалённых коллекций (Firestore) в DI-контейнере.
///
/// Назначение:
/// - Определяет фабрики для всех удалённых источников данных (коллекций Firestore);
/// - Централизует создание экземпляров классов, реализующих протоколы `CollectingProtocol`;
/// - Обеспечивает единую точку доступа к Firebase Firestore в слое Data.
///
/// Состав:
/// - `profileCollection`: `ProfileCollectingProtocol` — работа с коллекцией профилей пользователей (`ProfileCollection`);
/// - `catalogCollection`: `CatalogCollectingProtocol` — работа с коллекциями категорий, брендов и продуктов (`CatalogCollections`);
/// - `cartCollection`: `CartCollectingProtocol` — коллекция корзины пользователя (`CartCollection`);
/// - `favoritesCollection`: `FavoritesCollectingProtocol` — коллекция избранных товаров (`FavoritesCollection`);
/// - `ordersCollection`: `OrdersCollectingProtocol` — коллекция заказов (`OrdersCollection`).
///
/// Особенности:
/// - Все коллекции зарегистрированы как `.singleton`, поскольку Firestore оптимизирован для переиспользования соединений;
/// - Каждый класс реализует свой протокол и управляет CRUD-операциями с Firestore;
/// - Используется `FactoryKit` для декларативного объявления зависимостей;
/// - Контейнер выступает в роли точки инициализации и маршрутизации зависимостей между слоями Data/Repository.
/// 
/// Расширение входит в модуль **Dependency Injection (DI)**
/// и обеспечивает слой Data реализациями всех Firestore-коллекций приложения.

extension Container {
    
    // MARK: - Profile Remote (Firestore)
    
    var profileCollection: Factory<ProfileCollectingProtocol> {
        self {
            ProfileCollection()
        }.singleton
    }
    
    var catalogCollection: Factory<CatalogCollectingProtocol> {
        self {
            CatalogCollections()
        }.singleton
    }
    
    var cartCollection: Factory<CartCollectingProtocol> {
        self {
            CartCollection()
        }.singleton
    }
    
    var favoritesCollection: Factory<FavoritesCollectingProtocol> {
        self {
            FavoritesCollection()
        }.singleton
    }
    
    var ordersCollection: Factory<OrdersCollectingProtocol> {
        self {
            OrdersCollection()
        }.singleton
    }
}
