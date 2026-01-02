//
//  EditNameCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import UIKit

/// Координатор `EditNameCoordinator` управляет сценарием изменения имени пользователя.
///
/// Отвечает за:
/// - создание и конфигурацию `EditNameViewController`;
/// - инициализацию `EditNameViewModel` через `ViewModelBuildingProtocol`;
/// - управление навигацией (открытие, закрытие экрана, завершение сценария);
/// - получение `userId` из `AuthServiceProtocol`.
///
/// Особенности:
/// - использует `UINavigationController` для отображения экрана;
/// - скрывает нижний таббар при переходе на экран редактирования;
/// - изолирует логику переходов, обеспечивая чистоту View и ViewModel.

final class EditNameCoordinator: EditNameCoordinatingProtocol {

    // MARK: - Deps
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []

    private let viewModelFactory: ViewModelBuildingProtocol
    private let authService: AuthServiceProtocol
    
    var onFinish: (() -> Void)?

    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        viewModelFactory: ViewModelBuildingProtocol,
        authService: AuthServiceProtocol
    ) {
        self.navigation = navigation
        self.viewModelFactory = viewModelFactory
        self.authService = authService
    }

    // MARK: - Start
    
    func start() {
        let vm = viewModelFactory.makeEditNameViewModel(uid: authService.currentUserId ?? "")
        let vc = EditNameViewController(viewModel: vm)
        vc.hidesBottomBarWhenPushed = true

        vc.onBack = { [weak self] in
            self?.navigation.popViewController(animated: true)
        }
        vc.onFinish = { [weak self] in
            self?.navigation.popViewController(animated: true)
            self?.onFinish?()
        }

        navigation.pushViewController(vc, animated: true)
    }
}
