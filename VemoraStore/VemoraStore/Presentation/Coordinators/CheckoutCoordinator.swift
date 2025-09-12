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
            // Показываем экран успешного оформления
            self?.showOrderSuccess(orderId: nil)
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
    
    private func showOrderSuccess(orderId: String?) {
        let success = OrderSuccessCoordinator(navigation: navigation, orderId: orderId)
        
        success.onOpenOrder = { [weak self] orderId in
            // Открываем детали заказа
            let detailsVC = UIViewController()
            detailsVC.view.backgroundColor = .systemBackground
            detailsVC.title = "Заказ \(orderId ?? "")"
            self?.navigation.pushViewController(detailsVC, animated: true)
        }
        
        success.onFinish = { [weak self] in
            self?.remove(success)
        }
        
        add(success)
        success.start()
    }
}
