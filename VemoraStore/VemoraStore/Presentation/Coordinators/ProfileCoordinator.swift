//
//  ProfileCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 31.08.2025.
//

import UIKit
import FactoryKit

final class ProfileCoordinator: Coordinator {
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []

    var onLogout: (() -> Void)?

    private let authService: AuthServiceProtocol

    init(
        navigation: UINavigationController,
        authService: AuthServiceProtocol = Container.shared.authService()
    ) {
        self.navigation = navigation
        self.authService = authService
    }

    func start() {
        let vm = Container.shared.profileViewModel()
        let vc = ProfileViewController(viewModel: vm)

        vc.onLogout = { [weak self] in
            // здесь можно вызвать signOut и сообщить AppCoordinator
            try? self?.authService.signOut()
            self?.onLogout?()
        }

        navigation.setViewControllers([vc], animated: false)
    }
}
