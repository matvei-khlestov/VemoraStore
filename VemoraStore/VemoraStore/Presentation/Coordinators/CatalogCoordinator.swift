//
//  CatalogCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 31.08.2025.
//

import UIKit
import FactoryKit

final class CatalogCoordinator: Coordinator {
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []

    init(navigation: UINavigationController) {
        self.navigation = navigation
    }

    func start() {
        let vm = Container.shared.catalogViewModel()
        let vc = CatalogViewController(viewModel: vm)

        vc.onSelectProduct = { [weak self] product in
            self?.showDetails(for: product)
        }

        navigation.setViewControllers([vc], animated: false)
    }

    private func showDetails(for product: Product) {
        let makeVM = Container.shared.productDetailsViewModel
        let detailsVM = makeVM(product)
        let detailsVC = ProductDetailsViewController(viewModel: detailsVM)

        detailsVC.onCheckout = { [weak self] in
            self?.startCheckout()
        }

        navigation.pushViewController(detailsVC, animated: true)
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

