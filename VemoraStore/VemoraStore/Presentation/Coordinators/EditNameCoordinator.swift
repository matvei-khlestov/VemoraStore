//
//  EditNameCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import UIKit

final class EditNameCoordinator: EditNameCoordinatingProtocol {

    // MARK: - Deps
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []

    private let viewModelFactory: ViewModelBuildingProtocol
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
        let vm = viewModelFactory.makeEditNameViewModel()
        let vc = EditNameViewController(viewModel: vm)
        vc.hidesBottomBarWhenPushed = true

        vc.onBack = { [weak self] in
            self?.navigation.popViewController(animated: true)
        }
        vc.onFinish = { [weak self] in
            // вернёмся назад и сообщим наверх
            self?.navigation.popViewController(animated: true)
            self?.onFinish?()
        }

        navigation.pushViewController(vc, animated: true)
    }
}
