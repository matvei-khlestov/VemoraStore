//
//  ProfileGuestCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import UIKit

final class ProfileGuestCoordinator: ProfileGuestCoordinatingProtocol {
    
    // MARK: - Properties
    
    var navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    // Внешние события (например, при успешной авторизации)
    var onAuthCompleted: (() -> Void)?
    
    // Фабрики
    private let viewModelFactory: ViewModelBuildingProtocol
    private let coordinatorFactory: CoordinatorBuildingProtocol
    
    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        viewModelFactory: ViewModelBuildingProtocol,
        coordinatorFactory: CoordinatorBuildingProtocol
    ) {
        self.navigation = navigation
        self.viewModelFactory = viewModelFactory
        self.coordinatorFactory = coordinatorFactory
    }
    
    // MARK: - Start
    
    func start() {
        let vc = ProfileGuestViewController()
        
        vc.onLoginTap = { [weak self] in
            self?.openLogin()
        }
        vc.onAboutTap = { [weak self] in
            self?.openAbout()
        }
        vc.onContactTap = { [weak self] in
            self?.openContacts()
        }
        vc.onPrivacyTap = { [weak self] in
            self?.openPrivacy()
        }
        
        navigation.setViewControllers([vc], animated: false)
    }
}

// MARK: - Routing

private extension ProfileGuestCoordinator {
    func openLogin() {
        // Стартуем флоу авторизации через фабрику координаторов
        let auth = coordinatorFactory.makeAuthCoordinator(navigation: navigation)
        add(auth)
        auth.onFinish = { [weak self, weak auth] in
            guard let self else { return }
            if let auth { self.remove(auth) }
            // Сообщаем наружу, что авторизация завершена
            self.onAuthCompleted?()
        }
        auth.start()
    }
    
    func openAbout() {
        let coordinator = coordinatorFactory.makeAboutCoordinator(navigation: navigation)
        add(coordinator)
        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            self.remove(coordinator)
        }
        coordinator.start()
    }
    
    func openPrivacy() {
        let coordinator = coordinatorFactory.makePrivacyPolicyCoordinator(navigation: navigation)
        add(coordinator)
        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            self.remove(coordinator)
        }
        coordinator.start()
    }
    
    func openContacts() {
        let coordinator = coordinatorFactory.makeContactUsCoordinator(navigation: navigation)
        add(coordinator)
        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            self.remove(coordinator)
        }
        coordinator.start()
    }
}
