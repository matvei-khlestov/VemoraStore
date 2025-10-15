//
//  OrdersCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 18.09.2025.
//

import UIKit

final class OrdersCoordinator: OrdersCoordinatingProtocol {
    
    // MARK: - Coordinator
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    // MARK: - Callbacks
    
    var onFinish: (() -> Void)?
    
    // MARK: - Deps
    
    private let viewModelFactory: ViewModelBuildingProtocol
    private let authService: AuthServiceProtocol
    
    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        viewModelFactory: ViewModelBuildingProtocol,
        authService: AuthServiceProtocol
    ) {
        self.navigation = navigation
        self.viewModelFactory = viewModelFactory
        self.authService = authService
    }
    
    // MARK: - Start
    
    func start() {
        let userId = authService.currentUserId ?? ""
        let viewModel = viewModelFactory.makeOrdersViewModel(userId: userId)
        let vc = OrdersViewController(viewModel: viewModel)
        vc.hidesBottomBarWhenPushed = true
        
        vc.onBack = { [weak self] in
            guard let self else { return }
            self.navigation.popViewController(animated: true)
            self.onFinish?()
        }
        
        navigation.pushViewController(vc, animated: true)
    }
}
