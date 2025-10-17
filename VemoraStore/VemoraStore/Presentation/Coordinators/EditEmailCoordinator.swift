//
//  EditEmailCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import UIKit

/// Координатор `EditEmailCoordinator` управляет сценарием изменения e-mail пользователя.
///
/// Отвечает за:
/// - инициализацию `EditEmailViewModel` через `ViewModelBuildingProtocol`;
/// - создание и показ экрана `EditEmailViewController`;
/// - обработку переходов назад и завершения сценария (`onFinish`);
/// - получение идентификатора пользователя через `AuthServiceProtocol`.
///
/// Особенности:
/// - использует `UINavigationController` для управления навигацией;
/// - скрывает нижний таббар при отображении экрана редактирования e-mail;
/// - реализует чистую изоляцию навигационной логики вне View и ViewModel.

final class EditEmailCoordinator: EditEmailCoordinatingProtocol {
    
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
        let vm = viewModelFactory.makeEditEmailViewModel(userId: authService.currentUserId ?? "")
        let vc = EditEmailViewController(viewModel: vm)
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
