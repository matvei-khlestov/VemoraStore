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
    
    private let productId: String
    private let viewModelFactory: ViewModelBuildingProtocol
    private let coordinatorFactory: CoordinatorBuildingProtocol
    private let authService: AuthServiceProtocol
    
    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        productId: String,
        viewModelFactory: ViewModelBuildingProtocol,
        coordinatorFactory: CoordinatorBuildingProtocol,
        authService: AuthServiceProtocol
    ) {
        self.navigation = navigation
        self.productId = productId
        self.viewModelFactory = viewModelFactory
        self.coordinatorFactory = coordinatorFactory
        self.authService = authService
    }
    
    // MARK: - Start
    
    func start() {
        let userId = authService.currentUserId ?? ""
        let vm = viewModelFactory.makeProductDetailsViewModel(
            productId: productId,
            userId: userId
        )
        let vc = ProductDetailsViewController(viewModel: vm)
    
        vc.onBack = { [weak self] in
            self?.navigation.popViewController(animated: true)
        }
        
        navigation.pushViewController(vc, animated: true)
    }
}
