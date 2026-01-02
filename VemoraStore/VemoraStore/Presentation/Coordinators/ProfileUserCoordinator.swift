//
//  ProfileUserCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 17.09.2025.
//

import UIKit

/// Координатор `ProfileUserCoordinator` управляет сценарием отображения профиля пользователя.
///
/// Отвечает за:
/// - инициализацию и показ `ProfileUserViewController`;
/// - обработку навигации к экранам редактирования профиля, заказов, контактов,
///   политики конфиденциальности и информации "О нас";
/// - делегирование событий выхода из аккаунта и удаления пользователя через колбэки `onLogout` и `onDeleteAccount`.
///
/// Особенности:
/// - использует фабрики `ViewModelBuildingProtocol` и `CoordinatorBuildingProtocol` для создания зависимостей;
/// - добавляет и удаляет дочерние координаторы, предотвращая утечки памяти;
/// - полностью изолирует навигационную логику от слоя UI и ViewModel, следуя архитектуре Coordinator.

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
    private let authService: AuthServiceProtocol
    
    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        viewModelFactory: ViewModelBuildingProtocol,
        coordinatorFactory: CoordinatorBuildingProtocol,
        authService: AuthServiceProtocol
    ) {
        self.navigation = navigation
        self.viewModelFactory = viewModelFactory
        self.coordinatorFactory = coordinatorFactory
        self.authService = authService
    }
    
    // MARK: - Start
    
    func start() {
        let viewModel = viewModelFactory.makeProfileUserViewModel(uid: authService.currentUserId ?? "")
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
