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
        vc.onLogoutTap = { [weak self] in self?.confirmLogout() }
        vc.onDeleteAccountTap = { [weak self] in self?.confirmDeleteAccount() }
        
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
        // TODO: замените на ваш контроллер заказов
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.title = "Мои заказы"
        vc.hidesBottomBarWhenPushed = true
        navigation.pushViewController(vc, animated: true)
    }
    
    func openAbout() {
        let coordinator = AboutCoordinator(navigation: navigation)
        add(coordinator)
        coordinator.start()
    }
    
    func openPrivacy() {
        let coordinator = PrivacyPolicyCoordinator(navigation: navigation)
        add(coordinator)
        coordinator.start()
    }
    
    func openContacts() {
        let coordinator = ContactUsCoordinator(navigation: self.navigation)
        self.add(coordinator)
        coordinator.start()
    }
}

// MARK: - Alerts

private extension ProfileUserCoordinator {
    
    func confirmLogout() {
        let alert = UIAlertController(
            title: "Выйти из аккаунта?",
            message: "Вы сможете войти снова в любой момент.",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive, handler: { [weak self] _ in
            self?.onLogout?()
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        navigation.present(alert, animated: true)
    }
    
    func confirmDeleteAccount() {
        let alert = UIAlertController(
            title: "Удалить аккаунт?",
            message: "Это действие необратимо. Все данные будут удалены.",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Удалить аккаунт", style: .destructive, handler: { [weak self] _ in
            self?.onDeleteAccount?()
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        navigation.present(alert, animated: true)
    }
}
