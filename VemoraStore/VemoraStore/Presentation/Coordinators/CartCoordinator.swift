//
//  CartCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 31.08.2025.
//

import UIKit
import FactoryKit

final class CartCoordinator: Coordinator {
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }
    
    func start() {
        let vm = Container.shared.cartViewModel()
        let vc = CartViewController(viewModel: vm)
        
        vc.onCheckout = { [weak self] in
            self?.startCheckout()
        }
        
        vc.onSelectProduct = { [weak self] product in
            self?.showProductDetails(for: product)
        }
        
        navigation.setViewControllers([vc], animated: false)
    }
    
    private func startCheckout() {
        let checkout = CheckoutCoordinator(navigation: navigation)
        add(checkout)
        checkout.onFinish = { [weak self, weak checkout] in
            if let checkout { self?.remove(checkout) }
        }
        checkout.start()
    }
    
    private func showProductDetails(for product: Product) {
        let detailsCoordinator = ProductDetailsCoordinator(
            navigation: navigation,
            product: product
        )
        add(detailsCoordinator)
        detailsCoordinator.start()
    }
}
