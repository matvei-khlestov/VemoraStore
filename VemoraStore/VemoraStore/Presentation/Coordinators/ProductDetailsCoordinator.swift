//
//  ProductDetailsCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.09.2025.
//

import UIKit

final class ProductDetailsCoordinator: ProductDetailsCoordinatingProtocol {
    
    // MARK: - Properties
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let product: Product
    private let viewModelFactory: ViewModelBuildingProtocol
    private let coordinatorFactory: CoordinatorBuildingProtocol
    
    // MARK: - Init
    init(
        navigation: UINavigationController,
        product: Product,
        viewModelFactory: ViewModelBuildingProtocol,
        coordinatorFactory: CoordinatorBuildingProtocol
    ) {
        self.navigation = navigation
        self.product = product
        self.viewModelFactory = viewModelFactory
        self.coordinatorFactory = coordinatorFactory
    }
    
    // MARK: - Start
    func start() {
        let vm = viewModelFactory.makeProductDetailsViewModel(product: product)
        let vc = ProductDetailsViewController(viewModel: vm)
        
        vc.onCheckout = { [weak self] in
            self?.startCheckout()
        }
        vc.onBack = { [weak self] in
            self?.navigation.popViewController(animated: true)
        }
        
        navigation.pushViewController(vc, animated: true)
    }
    
    // MARK: - Private
    private func startCheckout() {
        let checkout = coordinatorFactory.makeCheckoutCoordinator(navigation: navigation)
        add(checkout)
        
        checkout.onFinish = { [weak self, weak checkout] in
            if let checkout { self?.remove(checkout) }
        }
        
        checkout.start()
    }
}
