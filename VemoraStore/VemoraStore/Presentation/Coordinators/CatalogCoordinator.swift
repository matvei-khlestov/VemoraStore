//
//  CatalogCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 31.08.2025.
//

import UIKit

final class CatalogCoordinator: CatalogCoordinatingProtocol {
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let viewModelFactory: ViewModelBuildingProtocol
    
    init(
        navigation: UINavigationController,
        viewModelFactory: ViewModelBuildingProtocol
    ) {
        self.navigation = navigation
        self.viewModelFactory = viewModelFactory
    }
    
    func start() {
        let vm = viewModelFactory.makeCatalogViewModel()
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

