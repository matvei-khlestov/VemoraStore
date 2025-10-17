//
//  EditPhoneCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import UIKit

/// Координатор `EditPhoneCoordinator` управляет потоком изменения номера телефона пользователя.
///
/// Отвечает за:
/// - создание и отображение экрана `EditPhoneViewController`;
/// - инициализацию `EditPhoneViewModel` через `ViewModelBuildingProtocol`;
/// - настройку форматирования номера через `PhoneFormattingProtocol`;
/// - навигацию назад и завершение сценария (`onFinish`).
///
/// Особенности:
/// - использует `AuthServiceProtocol` для получения `userId`;
/// - управляет переходами в рамках `UINavigationController`;
/// - скрывает нижний таббар при отображении экрана редактирования.

final class EditPhoneCoordinator: EditPhoneCoordinatingProtocol {
    
    // MARK: - Deps
    
    let navigation: UINavigationController
    
    var childCoordinators: [Coordinator] = []
    
    private let viewModelFactory: ViewModelBuildingProtocol
    private let authService: AuthServiceProtocol
    
    var onFinish: (() -> Void)?
    
    private let phoneFormatter: PhoneFormattingProtocol
    
    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        viewModelFactory: ViewModelBuildingProtocol,
        phoneFormatter: PhoneFormattingProtocol,
        authService: AuthServiceProtocol
    ) {
        self.navigation = navigation
        self.viewModelFactory = viewModelFactory
        self.phoneFormatter = phoneFormatter
        self.authService = authService
    }
    
    // MARK: - Start
    
    func start() {
        let vm = viewModelFactory.makeEditPhoneViewModel(userId: authService.currentUserId ?? "")
        let vc = EditPhoneViewController(
            viewModel: vm,
            phoneFormatter: phoneFormatter
        )
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
