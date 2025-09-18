//
//  OrdersCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 18.09.2025.
//

import UIKit
import FactoryKit

final class OrdersCoordinator: Coordinator {
    
    // MARK: - Coordinator
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    /// Сообщает родителю, что коорд. можно удалить (remove(child))
    var onFinish: (() -> Void)?
    
    // MARK: - Init
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }
    
    // MARK: - Start
    func start() {
        let viewModel = Container.shared.ordersViewModel()
        let vc = OrdersViewController(viewModel: viewModel)
        vc.hidesBottomBarWhenPushed = true
        
        // Навигация назад
        vc.onBack = { [weak self] in
            guard let self else { return }
            self.navigation.popViewController(animated: true)
            self.onFinish?()
        }
        
        navigation.pushViewController(vc, animated: true)
    }
}
