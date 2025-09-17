//
//  PrivacyPolicyCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 17.09.2025.
//

import UIKit

final class PrivacyPolicyCoordinator: Coordinator {
    
    // MARK: - Props
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    // MARK: - Init
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }
    
    // MARK: - Start
    
    func start() {
        let vc = PrivacyPolicyViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.onBack = { [weak self] in
            self?.navigation.popViewController(animated: true)
        }
        navigation.pushViewController(vc, animated: true)
    }
}
