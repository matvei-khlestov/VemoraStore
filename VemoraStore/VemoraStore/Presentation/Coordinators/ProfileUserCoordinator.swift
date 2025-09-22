//
//  ProfileUserCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 17.09.2025.
//

import UIKit
import FactoryKit

final class ProfileUserCoordinator: Coordinator {
    
    // MARK: - Coordinator
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    // MARK: - Callbacks (наружу)
    
    /// Сообщить аппа-уровню/родителю, что пользователь нажал «Выйти»
    var onLogout: (() -> Void)?
    /// Сообщить, что подтвердили удаление аккаунта
    var onDeleteAccount: (() -> Void)?
    
    // MARK: - Init
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }
    
    // MARK: - Start
    
    func start() {
        let viewModel = Container.shared.profileUserViewModel()
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
        
        navigation.setViewControllers([vc], animated: false)
    }
}

// MARK: - Navigation

private extension ProfileUserCoordinator {
    
    func openEditProfile() {
        // TODO: замените на ваш контроллер редактирования профиля
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.title = "Редактировать профиль"
        vc.hidesBottomBarWhenPushed = true
        navigation.pushViewController(vc, animated: true)
    }
    
    func openOrders() {
        let coordinator = OrdersCoordinator(navigation: navigation)
        add(coordinator)

        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            self.remove(coordinator)
        }

        coordinator.start()
    }
    
    func openAbout() {
        let coordinator = AboutCoordinator(navigation: navigation)
        add(coordinator)
        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            self.remove(coordinator)
        }
        coordinator.start()
    }
    
    func openPrivacy() {
        let coordinator = PrivacyPolicyCoordinator(navigation: navigation)
        add(coordinator)
        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            self.remove(coordinator)
        }
        coordinator.start()
    }
    
    func openContacts() {
        let coordinator = ContactUsCoordinator(navigation: self.navigation)
        add(coordinator)
        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            self.remove(coordinator)
        }
        coordinator.start()
    }
}
