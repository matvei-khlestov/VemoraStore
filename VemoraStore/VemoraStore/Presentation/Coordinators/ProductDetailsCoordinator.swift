//
//  ProductDetailsCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.09.2025.
//

import UIKit
import FactoryKit

final class ProductDetailsCoordinator: Coordinator {
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let product: Product
    
    init(navigation: UINavigationController, product: Product) {
        self.navigation = navigation
        self.product = product
    }
    
    func start() {
        let makeVM = Container.shared.productDetailsViewModel
        let vm = makeVM(product)
        let vc = ProductDetailsViewController(viewModel: vm)
        
        vc.onCheckout = { [weak self] in
            self?.startCheckout()
        }
        
        vc.onBack = { [weak self] in
            self?.navigation.popViewController(animated: true)
        }
        
        navigation.pushViewController(vc, animated: true)
    }
    
    private func startCheckout() {
        let checkout = CheckoutCoordinator(navigation: navigation)
        add(checkout)
        checkout.onFinish = { [weak self, weak checkout] in
            if let checkout { self?.remove(checkout) }
        }
        checkout.start()
    }
}
