//
//  ContactUsCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import UIKit

final class ContactUsCoordinator: Coordinator {
    
    // MARK: - Props
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    // MARK: - Init
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }
    
    // MARK: - Start
    
    func start() {
        let vc = ContactUsViewController()
        vc.onBack = { [weak self] in
            self?.navigation.popViewController(animated: true)
        }
        navigation.pushViewController(vc, animated: true)
    }
}
