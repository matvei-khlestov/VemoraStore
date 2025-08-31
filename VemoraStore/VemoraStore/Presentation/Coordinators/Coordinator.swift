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
    func store(_ child: Coordinator) { childCoordinators.append(child) }
    func free(_ child: Coordinator) { childCoordinators.removeAll { $0 === child } }
}
