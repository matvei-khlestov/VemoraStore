//
//  EditPhoneCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import UIKit

final class EditPhoneCoordinator: EditPhoneCoordinatingProtocol {

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
        let vm = viewModelFactory.makeEditPhoneViewModel()
        let vc = EditPhoneViewController(viewModel: vm)
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
