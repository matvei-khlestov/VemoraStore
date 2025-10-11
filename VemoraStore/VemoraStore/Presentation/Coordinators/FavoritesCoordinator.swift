//
//  FavoritesCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 31.08.2025.
//

import UIKit

final class FavoritesCoordinator: FavoritesCoordinatingProtocol {

    // MARK: - Routing
    
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
        let vm = viewModelFactory.makeFavoritesViewModel()
        let vc = FavoritesViewController(viewModel: vm)

        vc.onSelectProduct = { [weak self] product in
            self?.showProductDetails(for: product)
        }

        navigation.setViewControllers([vc], animated: false)
    }

    // MARK: - Private
    
    private func showProductDetails(for product: Product) {
        let details = coordinatorFactory.makeProductDetailsCoordinator(
            navigation: navigation,
            product: product
        )
        add(details)
        details.start()
    }

    private func startCheckout() {
        let checkout = coordinatorFactory.makeCheckoutCoordinator(navigation: navigation)
        add(checkout)
        checkout.onFinish = { [weak self, weak checkout] in
            if let checkout { self?.remove(checkout) }
        }
        checkout.start()
    }
}
