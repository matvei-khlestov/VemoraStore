//
//  AboutCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import UIKit

final class AboutCoordinator: Coordinator {
    
    // MARK: - Properties
    
    var navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    // MARK: - Init
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }
    
    // MARK: - Start
    
    func start() {
        let controller = AboutViewController()
        
        controller.onBack = { [weak self] in
            self?.navigation.popViewController(animated: true)
        }
        
        navigation.pushViewController(controller, animated: true)
    }
}
