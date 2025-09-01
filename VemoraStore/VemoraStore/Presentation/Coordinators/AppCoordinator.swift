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

    private let authService: AuthServiceProtocol

    init(
        navigation: UINavigationController,
        authService: AuthServiceProtocol = Container.shared.authService()
    ) {
        self.navigation = navigation
        self.authService = authService
    }

    func start() {
        showMain()
    }

    // MARK: - Public helper (по требованию просим авторизацию и потом выполняем completion)
    func requireAuth(completion: @escaping () -> Void) {
        if authService.currentUserId != nil {
            completion()
            return
        }
        showAuth(onFinish: completion)
    }

    // MARK: - Flows
    private func showAuth(onFinish: (() -> Void)? = nil) {
        navigation.setNavigationBarHidden(false, animated: false)

        let auth = AuthCoordinator(navigation: navigation, authService: authService)
        add(auth)
        auth.onFinish = { [weak self, weak auth] in
            if let auth { self?.remove(auth) }
            onFinish?() ?? self?.showMain()
        }
        auth.start()
    }

    private func showMain() {
        navigation.setNavigationBarHidden(true, animated: false)

        let main = MainCoordinator(navigation: navigation)
        add(main)
        main.onLogout = { [weak self, weak main] in
            if let main { self?.remove(main) }
            self?.showAuth()
        }
        main.start()
    }
}

