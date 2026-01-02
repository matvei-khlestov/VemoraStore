//
//  Container+Factories.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import Foundation
import FactoryKit

/// Расширение `Container+Factories` — регистрация фабрик верхнего уровня (ViewModel, Coordinator, Screen) в DI-контейнере.
///
/// Назначение:
/// - Определяет зависимости для основных фабрик, используемых в слоях Presentation и Navigation;
/// - Централизует создание экземпляров фабрик, упрощая доступ и тестирование;
/// - Используется для внедрения зависимостей во ViewModel и координаторы.
///
/// Состав:
/// - `viewModelFactory`: `ViewModelBuildingProtocol` — отвечает за создание всех ViewModel приложения;
/// - `coordinatorFactory`: `CoordinatorBuildingProtocol` — создаёт координаторы для навигации между экранами;
/// - `screenFactory`: `ScreenFactoryProtocol` — генерирует контроллеры экранов (`UIViewController`) на основе моделей.
///
/// Особенности:
/// - Все фабрики зарегистрированы как `.singleton`, что обеспечивает единый экземпляр в течение жизненного цикла приложения;
/// - Используется `FactoryKit` для декларативного описания зависимостей и автоматического внедрения контейнера;
/// - Реализации фабрик (`ViewModelFactory`, `CoordinatorFactory`, `ScreenFactory`) используют `Container` для резолвинга конкретных зависимостей.
///
/// Расширение входит в модуль **Dependency Injection Layer**
/// и обеспечивает слой Presentation фабриками, отвечающими за сборку экранов, навигацию и ViewModel.

extension Container {
    
    // MARK: - Factory
    
    var viewModelFactory: Factory<ViewModelBuildingProtocol> {
        self {
            ViewModelFactory(container: self)
        }.singleton
    }
    
    var coordinatorFactory: Factory<CoordinatorBuildingProtocol> {
        self {
            CoordinatorFactory(container: self) 
        }.singleton
    }
    
    var screenFactory: Factory<ScreenFactoryProtocol> {
        self {
            ScreenFactory(container: self)
        }.singleton
    }
}
