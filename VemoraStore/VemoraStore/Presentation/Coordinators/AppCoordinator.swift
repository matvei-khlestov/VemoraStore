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
        
        ////        showDebugImport()
                showMain()
//        if authService.currentUserId != nil {
//            showMain()
//        } else {
//            showAuth()
//        }
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
            guard let self else { return }
            if let auth { self.remove(auth) }
            if let onFinish {
                onFinish()
            } else {
                self.showMain()
            }
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
        
        main.onDeleteAccount = { [weak self, weak main] in
            if let main { self?.remove(main) }
            self?.showAuth()
        }
        
        main.onOrderSuccess = { [weak self, weak main] in
            guard let self else { return }
            if let main { self.remove(main) }
            self.showOrderSuccess()
        }
        main.start()
    }
    
    private func showOrderSuccess() {
        let success = coordinatorFactory.makeOrderSuccessCoordinator(
            navigation: navigation
        )
        add(success)
        
        success.onOpenCatalog = { [weak self, weak success] in
            guard let self else { return }
            if let success {
                self.remove(success)
            }
            self.showMain()
        }
        
        success.onFinish = { [weak self, weak success] in
            if let success {
                self?.remove(success)
            }
        }
        
        success.start()
    }
    
#if DEBUG
    private func showDebugImport() {
        let debug = coordinatorFactory.makeDebugCoordinator(navigation: navigation)
        add(debug)
        debug.onFinish = { [weak self, weak debug] in
            if let debug { self?.remove(debug) }
        }
        debug.start()
    }
#endif
}
