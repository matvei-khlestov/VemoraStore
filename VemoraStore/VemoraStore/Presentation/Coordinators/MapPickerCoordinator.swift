//
//  MapPickerCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.09.2025.
//

import UIKit

final class MapPickerCoordinator: Coordinator {

    // MARK: - Public callbacks
    
    /// Сообщит, что координатор завершил работу (можно убрать из childCoordinators)
    var onFinish: (() -> Void)?
    var onFullAddressPicked: ((String) -> Void)?

    // MARK: - Deps
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []

    // MARK: - Init
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }

    // MARK: - Start
    func start() {
        let vc = MapPickerViewController()

        vc.onAddressComposed = { [weak self] fullAddress in
            guard let self else { return }
            self.onFullAddressPicked?(fullAddress)
            self.navigation.popViewController(animated: true)
            self.onFinish?()
        }

        vc.onBack = { [weak self] in
            guard let self else { return }
            self.navigation.popViewController(animated: true)
            self.onFinish?()
        }

        navigation.pushViewController(vc, animated: true)
    }
}
