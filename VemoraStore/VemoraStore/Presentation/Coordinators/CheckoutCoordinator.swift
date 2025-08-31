//
//  CheckoutCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 31.08.2025.
//

import UIKit
import FactoryKit

final class CheckoutCoordinator: Coordinator {
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    var onFinish: (() -> Void)?
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }
    
    func start() {
        let vm = Container.shared.checkoutViewModel()
        let vc = CheckoutViewController(viewModel: vm)
        
        vc.onPickOnMap = { [weak self] in
            self?.showMapPicker()
        }
        vc.onFinished = { [weak self] in
            self?.onFinish?()
        }
        
        navigation.pushViewController(vc, animated: true)
    }
    
    private func showMapPicker() {
        let mapVC = MapPickerViewController()
        navigation.pushViewController(mapVC, animated: true)
    }
}
