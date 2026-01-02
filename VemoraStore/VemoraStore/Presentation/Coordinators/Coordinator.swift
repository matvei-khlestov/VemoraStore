//
//  Coordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit

/// Базовый протокол координатора, определяющий общую структуру всех навигационных флоу.
///
/// Отвечает за:
/// - хранение основного `UINavigationController`;
/// - управление жизненным циклом дочерних координаторов;
/// - запуск основного сценария через метод `start()`.
///
/// Особенности:
/// - позволяет добавлять и удалять дочерние координаторы,
///   предотвращая утечки памяти;
/// - используется как базовый контракт для всех координаторов приложения.

protocol Coordinator: AnyObject {
    /// Главный навигационный контроллер, через который происходит показ экранов.
    var navigation: UINavigationController { get }
    
    /// Дочерние координаторы, ответственные за подмодули или вложенные флоу.
    var childCoordinators: [Coordinator] { get set }
    
    /// Точка входа координатора — метод, запускающий соответствующий флоу.
    func start()
}

extension Coordinator {
    /// Добавляет дочерний координатор в список активных.
    func add(_ child: Coordinator) {
        childCoordinators.append(child)
    }
    
    /// Удаляет дочерний координатор из списка активных.
    func remove(_ child: Coordinator) {
        childCoordinators.removeAll { $0 === child }
    }
}
