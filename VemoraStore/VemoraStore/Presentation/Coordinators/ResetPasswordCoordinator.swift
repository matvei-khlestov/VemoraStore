//
//  ResetPasswordCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 21.09.2025.
//

import UIKit

final class ResetPasswordCoordinator: ResetPasswordCoordinatingProtocol {

    // MARK: - Deps
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let viewModelFactory: ViewModelBuildingProtocol

    // MARK: - Callbacks
    
    var onFinish: (() -> Void)?

    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        viewModelFactory: ViewModelBuildingProtocol
    ) {
        self.navigation = navigation
        self.viewModelFactory = viewModelFactory
    }

    // MARK: - Start
    
    func start() {
        let vm = viewModelFactory.makeResetPasswordViewModel()
        let vc = ResetPasswordViewController(viewModel: vm)
        vc.hidesBottomBarWhenPushed = true

        vc.onBack = { [weak self] in
            guard let self else { return }
            self.navigation.popViewController(animated: true)
            self.onFinish?()
        }

        vc.onDone = { [weak self] in
            guard let self else { return }
            self.navigation.popViewController(animated: true)
            self.onFinish?()
        }

        navigation.pushViewController(vc, animated: true)
    }
}
