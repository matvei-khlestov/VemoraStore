//
//  CartCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 31.08.2025.
//

import UIKit

final class CartCoordinator: CartCoordinatingProtocol {
    
    // MARK: - Props
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    var onOrderSuccess: (() -> Void)?
    
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
        let vm = viewModelFactory.makeCartViewModel()
        let vc = CartViewController(viewModel: vm)
        
        vc.onCheckout = { [weak self] in
            self?.showCheckout()
        }
        
        vc.onSelectProduct = { [weak self] product in
            self?.showProductDetails(for: product)
        }
        
        navigation.setViewControllers([vc], animated: false)
    }
    
    // MARK: - Flows
    
    private func showCheckout() {
        let checkout = coordinatorFactory.makeCheckoutCoordinator(navigation: navigation)
        add(checkout)
        
        checkout.onOrderSuccess = { [weak self, weak checkout] in
            guard let self else { return }
            if let checkout { self.remove(checkout) }
            self.onOrderSuccess?()
        }
        
        checkout.onFinish = { [weak self, weak checkout] in
            if let checkout { self?.remove(checkout) }
        }
        
        checkout.start()
    }
    
    private func showProductDetails(for product: ProductTest) {
        let details = coordinatorFactory.makeProductDetailsCoordinator(
            navigation: navigation,
            product: product
        )
        add(details)
        details.start()
    }
}
