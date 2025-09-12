//
//  MapPickerCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.09.2025.
//

import UIKit

final class MapPickerCoordinator: Coordinator {

    // MARK: - Public callbacks
    /// Вернёт выбранный адрес вверх по иерархии
    var onAddressPicked: ((Address) -> Void)?
    /// Сообщит, что координатор завершил работу (можно убрать из childCoordinators)
    var onFinish: (() -> Void)?

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

        vc.onPickAddress = { [weak self] address in
            guard let self else { return }
            self.onAddressPicked?(address)
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
