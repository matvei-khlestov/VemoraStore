//
//  Container+UITestBootstrap.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import FactoryKit
import UIKit

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
