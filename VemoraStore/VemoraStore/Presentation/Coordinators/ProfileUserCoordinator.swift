//
//  ProfileUserCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 17.09.2025.
//

import UIKit

final class ProfileUserCoordinator: ProfileUserCoordinatingProtocol {
    
    // MARK: - Coordinator
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    // MARK: - Callbacks (наружу)
    
    var onLogout: (() -> Void)?
    var onDeleteAccount: (() -> Void)?
    
    // MARK: - Factories
    
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
        let viewModel = viewModelFactory.makeProfileUserViewModel()
        let vc = ProfileUserViewController(viewModel: viewModel)
        
        // Роутинг по ячейкам
        vc.onEditProfileTap = { [weak self] in self?.openEditProfile() }
        vc.onOrdersTap      = { [weak self] in self?.openOrders() }
        vc.onAboutTap       = { [weak self] in self?.openAbout() }
        vc.onContactTap     = { [weak self] in self?.openContacts() }
        vc.onPrivacyTap     = { [weak self] in self?.openPrivacy() }
        
        // Кнопки снизу
        vc.onLogoutTap = { [weak self] in self?.onLogout?() }
        vc.onDeleteAccountTap = { [weak self] in self?.onDeleteAccount?() }
        vc.onEditProfileTap = { [weak self] in self?.openEditProfile() }
        
        navigation.setViewControllers([vc], animated: false)
    }
}

// MARK: - Navigation

private extension ProfileUserCoordinator {
    
    func openEditProfile() {
        let coordinator = coordinatorFactory.makeEditProfileCoordinator(navigation: navigation)
        add(coordinator)
        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            self.remove(coordinator)
        }
        coordinator.start()
    }
    
    func openOrders() {
        let coordinator = coordinatorFactory.makeOrdersCoordinator(navigation: navigation)
        add(coordinator)
        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            self.remove(coordinator)
        }
        coordinator.start()
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
