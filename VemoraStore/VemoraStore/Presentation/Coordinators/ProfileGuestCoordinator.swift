//
//  ProfileGuestCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import UIKit
import SafariServices

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
            self?.callSupport()
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
        // В реальном проекте тут можно вызвать AuthCoordinator
        let alert = UIAlertController(
            title: "Вход",
            message: "Открыть экран авторизации",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Готово", style: .default, handler: { [weak self] _ in
            self?.onAuthCompleted?()
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        navigation.present(alert, animated: true)
    }
    
    func openAbout() {
        let coordinator = AboutCoordinator(navigation: navigation)
        add(coordinator)
        coordinator.start()
    }
    
    func openPrivacy() {
        if let url = URL(string: "https://vemora.example.com/privacy") {
            let safari = SFSafariViewController(url: url)
            navigation.present(safari, animated: true)
        } else {
            showInfo("Политика конфиденциальности временно недоступна.")
        }
    }
    
    func callSupport() {
        let number = "+78001234567" // подставь актуальный номер
        if let url = URL(string: "tel://\(number)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            showInfo("Не удалось открыть звонилку.")
        }
    }
    
    func showInfo(_ text: String) {
        let alert = UIAlertController(title: "Vemora", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        navigation.present(alert, animated: true)
    }
}
