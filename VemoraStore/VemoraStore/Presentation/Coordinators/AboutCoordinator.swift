//
//  AboutCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import UIKit

final class AboutCoordinator: AboutCoordinatingProtocol {
    
    // MARK: - Properties
    
    var navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    var onFinish: (() -> Void)?
    
    // MARK: - Init
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }
    
    // MARK: - Start
    
    func start() {
        let controller = AboutViewController()
        controller.hidesBottomBarWhenPushed = true
        controller.onBack = { [weak self] in
            self?.navigation.popViewController(animated: true)
            self?.onFinish?()
        }
        
        navigation.pushViewController(controller, animated: true)
    }
}
