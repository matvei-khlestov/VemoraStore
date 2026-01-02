//
//  Container+UITestBootstrap.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import FactoryKit
import UIKit

/// Модуль `Container+UITestBootstrap` — вспомогательная интеграция для UI-тестов.
///
/// Назначение:
/// - Подготавливает тестовый `rootViewController` без запуска основного координатора приложения;
/// - Позволяет инициализировать минимальный UI-контейнер через DI (`FactoryKit`);
/// - Упрощает запуск UI-тестов без модификации боевого кода.
///
/// Структура:
/// - `UITestRoot` — точка входа для тестов (доступна только при `#if DEBUG`);
///   - `uiTestBootstrap` — резолвит `UITestBootstrap` из DI-контейнера;
///   - `makeRootController()` — создаёт `UIViewController`, если тест требует Root-UI;
/// - `Container.uiTestBootstrap` — регистрация фабрики `UITestBootstrap` в DI.
///
/// Особенности:
/// - Активируется только при `#if DEBUG` (в продакшн-сборку не попадает);
/// - Позволяет создавать тестовый корень интерфейса напрямую (без AppCoordinator);
/// - Поддерживает изоляцию тестов — `Container.shared` остаётся независимым;
/// - Используется в UI-тестах для подготовки стартового состояния приложения.
///
/// Используется совместно с:
/// - `UITestBootstrap` — класс, создающий тестовую среду и контроллер;
/// - `FactoryKit.Container` — для регистрации тестовых зависимостей.

#if DEBUG
enum UITestRoot {
    
    /// Bootstrap для UI-тестов
    private static var uiTestBootstrap: UITestBootstrap {
        Container.shared.uiTestBootstrap()
    }
    
    /// Возвращает готовый rootViewController для UI-тестов
    static func makeRootController() -> UIViewController? {
        uiTestBootstrap.makeRootControllerIfNeeded()
    }
}

extension Container {
    /// Регистрация Bootstrap в DI (через FactoryKit)
    var uiTestBootstrap: Factory<UITestBootstrap> {
        self { UITestBootstrap(container: .shared) }
    }
}
#endif
