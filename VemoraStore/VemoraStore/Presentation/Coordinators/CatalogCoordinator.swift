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
}

