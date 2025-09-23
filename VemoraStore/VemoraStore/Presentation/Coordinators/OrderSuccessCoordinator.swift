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

    var onOpenOrder: (() -> Void)?
    var onFinish: (() -> Void)?

    // MARK: - Init
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }

    // MARK: - Start
    
    func start() {
        let vc = OrderSuccessViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.onViewOrder = { [weak self] in
            self?.onOpenOrder?()
        }
        navigation.pushViewController(vc, animated: true)
    }

    func finish() {
        onFinish?()
    }
}
