//
//  EditEmailCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import UIKit

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
