//
//  ProductDetailsCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.09.2025.
//

import UIKit

/// Координатор `ProductDetailsCoordinator` управляет сценарием отображения карточки товара.
///
/// Отвечает за:
/// - инициализацию и показ `ProductDetailsViewController`;
/// - передачу идентификатора товара и пользователя в `ProductDetailsViewModel`;
/// - обработку навигации назад.
///
/// Особенности:
/// - использует фабрики `ViewModelBuildingProtocol` и `CoordinatorBuildingProtocol` для создания зависимостей;
/// - скрывает навигационную логику от слоя ViewModel;
/// - реализует изолированный сценарий показа деталей товара в рамках архитектуры Coordinator.

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
