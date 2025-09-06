//
//  FavoritesCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 31.08.2025.
//

import UIKit
import FactoryKit

final class FavoritesCoordinator: Coordinator {
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }
    
    func start() {
        let vm = Container.shared.favoritesViewModel()
        let vc = FavoritesViewController(viewModel: vm)
        
        vc.onSelectProduct = { [weak self] product in
            self?.showProductDetails(for: product)
        }
        
        navigation.setViewControllers([vc], animated: false)
    }
    
    private func showProductDetails(for product: Product) {
        let detailsCoordinator = ProductDetailsCoordinator(
            navigation: navigation,
            product: product
        )
        add(detailsCoordinator)
        detailsCoordinator.start()
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
