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
        
        vc.onBack = { [weak self] in
            self?.navigation.popViewController(animated: true)
        }
        
        navigation.pushViewController(vc, animated: true)
    }
    
    private func showMapPicker() {
        let picker = MapPickerCoordinator(navigation: navigation)
        add(picker)
        
        picker.onAddressPicked = { [weak self, weak picker] address in
            guard let self else { return }
            // self.viewModel.address = address
            
            if let picker { self.remove(picker) }
        }
        
        picker.onFinish = { [weak self, weak picker] in
            if let picker { self?.remove(picker) }
        }
        
        picker.start()
    }
}
