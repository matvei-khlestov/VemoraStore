//
//  CatalogCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 31.08.2025.
//

import UIKit

final class CatalogCoordinator: CatalogCoordinatingProtocol {
    
    // MARK: - Properties
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    // MARK: - Factories
    
    private let viewModelFactory: ViewModelBuildingProtocol
    private let coordinatorFactory: CoordinatorBuildingProtocol
    
    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        viewModelFactory: ViewModelBuildingProtocol,
        coordinatorFactory: CoordinatorBuildingProtocol
    ) {
        self.navigation = navigation
        self.viewModelFactory = viewModelFactory
        self.coordinatorFactory = coordinatorFactory
    }
    
    // MARK: - Start
    
    func start() {
        let vm = viewModelFactory.makeCatalogViewModel()
        let vc = CatalogViewController(viewModel: vm)
        
        vc.onSelectProduct = { [weak self] product in
            self?.showProductDetails(for: product)
        }
        
        navigation.setViewControllers([vc], animated: false)
    }
    
    // MARK: - Private
    
    private func showProductDetails(for product: ProductTest) {
        let detailsCoordinator = coordinatorFactory.makeProductDetailsCoordinator(
            navigation: navigation,
            product: product
        )
        add(detailsCoordinator)
        detailsCoordinator.start()
    }
}

