//
//  Coordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigation: UINavigationController { get }
    var childCoordinators: [Coordinator] { get set }
    func start()
}

extension Coordinator {
    func add(_ child: Coordinator) { childCoordinators.append(child) }
    func remove(_ child: Coordinator) { childCoordinators.removeAll { $0 === child } }
}
