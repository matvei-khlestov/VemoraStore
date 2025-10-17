//
//  Container+Repositories.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import FactoryKit

/// Расширение `Container+Repositories` — регистрация всех репозиториев данных в DI-контейнере.
///
/// Назначение:
/// - Связывает все репозитории (`Repository`) с их зависимостями (`remote` и `local`);
/// - Определяет, какие репозитории создаются как singletons, а какие — параметризированные по `userId`;
/// - Централизует точки доступа к источникам данных для слоёв ViewModel и сервисов.
///
/// Состав:
/// - `profileRepository`: `ParameterFactory<String, ProfileRepository>`
///   Создаёт `DefaultProfileRepository` для конкретного пользователя (по `uid`).
///
/// - `catalogRepository`: `Factory<CatalogRepository>`
///   Singleton-репозиторий каталога (`DefaultCatalogRepository`), общедоступный для всего приложения.
///
/// - `cartRepository`: `ParameterFactory<String, CartRepository>`
///   Создаёт `DefaultCartRepository` с привязкой к `userId` (локальная корзина + Firestore + CatalogStore).
///
/// - `favoritesRepository`: `ParameterFactory<String, FavoritesRepository>`
///   Репозиторий избранного (`DefaultFavoritesRepository`), работает с локальным и удалённым источниками.
///
/// - `ordersRepository`: `ParameterFactory<String, OrdersRepository>`
///   Репозиторий заказов (`DefaultOrdersRepository`), синхронизирует локальные и удалённые заказы пользователя.
///
/// Особенности:
/// - Используется `FactoryKit` для декларативного построения зависимостей;
/// - `ParameterFactory` позволяет создавать экземпляры с контекстом `userId`;
/// - `catalogRepository` зарегистрирован как singleton, т.к. общий для всех пользователей;
/// - Остальные репозитории — user-scoped, создаются по запросу;
/// - Все зависимости резолвятся из контейнера (`self`) для единообразия.
///
/// Расширение входит в модуль **Dependency Injection (DI)** и обеспечивает слой Data репозиториями.

extension Container {
    var profileRepository: ParameterFactory<String, ProfileRepository> {
        self { uid in
            DefaultProfileRepository(
                remote: self.profileCollection(),
                local: self.profileLocalStore(),
                userId: uid
            )
        }
    }
    
    var catalogRepository: Factory<CatalogRepository> {
        self {
            DefaultCatalogRepository(
                remote: self.catalogCollection(),
                local: self.catalogLocalStore()
            )
        }.singleton
    }
    
    var cartRepository: ParameterFactory<String, CartRepository> {
        self { uid in
            DefaultCartRepository(
                remote: self.cartCollection(),
                local: self.cartLocalStore(),
                catalog: self.catalogLocalStore(),
                userId: uid
            )
        }
    }
    
    var favoritesRepository: ParameterFactory<String, FavoritesRepository> {
        self { uid in
            DefaultFavoritesRepository(
                remote: self.favoritesCollection(),
                local: self.favoritesLocalStore(),
                catalog: self.catalogLocalStore(),
                userId: uid
            )
        }
    }
    
    var ordersRepository: ParameterFactory<String, OrdersRepository> {
        self { uid in
            DefaultOrdersRepository(
                remote: self.ordersCollection(),
                local: self.ordersLocalStore(),
                userId: uid
            )
        }
    }
}
