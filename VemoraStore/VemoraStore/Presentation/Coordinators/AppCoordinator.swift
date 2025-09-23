//
//  AppCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit

final class AppCoordinator: AppCoordinatingProtocol {
    
    // MARK: - Deps
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let authService: AuthServiceProtocol
    private let coordinatorFactory: CoordinatorBuildingProtocol
    
    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        authService: AuthServiceProtocol,
        coordinatorFactory: CoordinatorBuildingProtocol
    ) {
        self.navigation = navigation
        self.authService = authService
        self.coordinatorFactory = coordinatorFactory
    }
    
    // MARK: - Start
    
    func start() {
        showMain()
    }
    
    // MARK: - Public helper
    
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
        
        let auth = coordinatorFactory.makeAuthCoordinator(navigation: navigation)
        add(auth)
        auth.onFinish = { [weak self, weak auth] in
            if let auth { self?.remove(auth) }
            onFinish?() ?? self?.showMain()
        }
        auth.start()
    }
    
    private func showMain() {
        navigation.setNavigationBarHidden(true, animated: false)
        
        let main = coordinatorFactory.makeMainCoordinator(navigation: navigation)
        add(main)
        main.onLogout = { [weak self, weak main] in
            if let main { self?.remove(main) }
            self?.showAuth()
        }
        main.start()
    }
}

