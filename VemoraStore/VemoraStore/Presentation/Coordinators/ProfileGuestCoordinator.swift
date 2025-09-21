//
//  ProfileGuestCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import UIKit
import SafariServices
import FactoryKit

final class ProfileGuestCoordinator: Coordinator {
    
    // MARK: - Properties
    
    var navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    // Внешние события (например, при успешной авторизации)
    var onAuthCompleted: (() -> Void)?
    
    // MARK: - Init
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
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
        // Стартуем флоу авторизации через координатор
        let auth = AuthCoordinator(
            navigation: navigation,
            authService: Container.shared.authService()
        )
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
    
    func showInfo(_ text: String) {
        let alert = UIAlertController(title: "Vemora", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        navigation.present(alert, animated: true)
    }
}
