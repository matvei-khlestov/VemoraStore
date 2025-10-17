//
//  CompositionRoot.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import FactoryKit

/// Точка композиции зависимостей (`CompositionRoot`) — базовая фабрика верхнего уровня приложения.
///
/// Назначение:
/// - Определяет корневые фабрики для ключевых сервисов и координаторов;
/// - Используется при инициализации приложения (AppDelegate / SceneDelegate);
/// - Является входной точкой в систему зависимостей, построенную через `FactoryKit`.
///
/// Состав:
/// - `makeCoordinatorFactory()`:
///   Возвращает экземпляр `CoordinatorFactory`, реализующий `CoordinatorBuildingProtocol`.
///   Используется для создания всех координаторов приложения (Auth, Main, Catalog и др.).
///
/// - `makeAuthService()`:
///   Возвращает текущую реализацию сервиса аутентификации (`AuthServiceProtocol`),
///   зарегистрированную в контейнере `Container.shared`.
///
/// Особенности:
/// - `CompositionRoot` централизует создание основных зависимостей,
///   не допуская прямых вызовов `Container.shared` в UI или AppDelegate;
/// - Упрощает тестирование и переиспользование — можно подменить реализации зависимостей;
/// - Не хранит состояние, использует статические фабричные методы.
///
/// Пример использования:
/// ```swift
/// let coordinatorFactory = CompositionRoot.makeCoordinatorFactory()
/// let authService = CompositionRoot.makeAuthService()
/// let authCoordinator = coordinatorFactory.makeAuthCoordinator(navigation: nav)
/// ```
///
/// Модуль относится к **Dependency Injection Layer**
/// и служит точкой входа для инициализации архитектуры приложения.

enum CompositionRoot {
    static func makeCoordinatorFactory() -> CoordinatorBuildingProtocol {
        CoordinatorFactory(container: Container.shared)
    }
    
    static func makeAuthService() -> AuthServiceProtocol {
        Container.shared.authService()
    }
}
