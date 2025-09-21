//
//  ResetPasswordCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 21.09.2025.
//

import UIKit
import FactoryKit

final class ResetPasswordCoordinator: Coordinator {

    // MARK: - Deps
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []

    // MARK: - Callbacks
    var onFinish: (() -> Void)?

    // MARK: - Init
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }

    // MARK: - Start
    func start() {
        let vm = Container.shared.passwordResetViewModel()
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
