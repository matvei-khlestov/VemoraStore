//
//  AppCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit
import FactoryKit

final class AppCoordinator: Coordinator {
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []

    // deps
    private let authService: AuthServiceProtocol

    init(
        navigation: UINavigationController,
        authService: AuthServiceProtocol = Container.shared.authService()
    ) {
        self.navigation = navigation
        self.authService = authService
    }

    func start() {
        if authService.currentUserId != nil {
            showMain()
        } else {
            showAuth()
        }
    }

    private func showAuth() {
        let auth = AuthCoordinator(navigation: navigation, authService: authService)
        store(auth)
        auth.onFinish = { [weak self, weak auth] in
            if let auth { self?.free(auth) }
            self?.showMain()
        }
        auth.start()
    }

    private func showMain() {
        let main = MainCoordinator(navigation: navigation)
        store(main)
        main.onLogout = { [weak self, weak main] in
            if let main { self?.free(main) }
            self?.showAuth()
        }
        main.start()
    }
}
