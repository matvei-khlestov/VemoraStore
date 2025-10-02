//
//  OrderSuccessCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.09.2025.
//

import UIKit

final class OrderSuccessCoordinator: OrderSuccessCoordinatingProtocol {
    
    // MARK: - Routing
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    var onOpenCatalog: (() -> Void)?
    var onFinish: (() -> Void)?
    
    // MARK: - Factories
    
    private let coordinatorFactory: CoordinatorBuildingProtocol
    
    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        coordinatorFactory: CoordinatorBuildingProtocol
    ) {
        self.navigation = navigation
        self.coordinatorFactory = coordinatorFactory
    }
    
    // MARK: - Start
    
    func start() {
        let vc = OrderSuccessViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.onViewCatalog = { [weak self] in
            self?.onOpenCatalog?()
        }
        navigation.pushViewController(vc, animated: true)
    }
}
