//
//  CategoryProductsCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 07.10.2025.
//

import UIKit

/// Координатор `CategoryProductsCoordinator` управляет сценарием показа товаров конкретной категории.
///
/// Отвечает за:
/// - инициализацию и показ `CategoryProductsViewController`;
/// - передачу идентификатора категории и пользователя в `CategoryProductsViewModel`;
/// - навигацию к экрану деталей товара (`ProductDetailsCoordinator`);
/// - обработку события возврата назад.
///
/// Особенности:
/// - изолирует логику навигации от слоя ViewModel;
/// - использует фабрики `ViewModelBuildingProtocol` и `CoordinatorBuildingProtocol` для построения зависимостей;
/// - реализует навигацию в рамках архитектуры Coordinator, обеспечивая переиспользуемость и модульность.

final class CategoryProductsCoordinator: CategoryProductsCoordinatingProtocol {
    
    // MARK: - Properties
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    // MARK: - Factories
    
    private let viewModelFactory: ViewModelBuildingProtocol
    private let coordinatorFactory: CoordinatorBuildingProtocol
    private let authService: AuthServiceProtocol
    
    // MARK: - Input
    
    private let categoryId: String
    private let categoryTitle: String
    
    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        viewModelFactory: ViewModelBuildingProtocol,
        coordinatorFactory: CoordinatorBuildingProtocol,
        authService: AuthServiceProtocol,
        categoryId: String,
        categoryTitle: String
    ) {
        self.navigation = navigation
        self.viewModelFactory = viewModelFactory
        self.coordinatorFactory = coordinatorFactory
        self.authService = authService
        self.categoryId = categoryId
        self.categoryTitle = categoryTitle
    }
    
    // MARK: - Start
    
    func start() {
        let userId = authService.currentUserId ?? ""
        let vm = viewModelFactory.makeCategoryProductsViewModel(
            categoryId: categoryId,
            userId: userId
        )
        let vc = CategoryProductsViewController(viewModel: vm)
        
        vc.title = categoryTitle
        
        vc.onSelectProduct = { [weak self] product in
            self?.showProductDetails(for: product.id)
        }
        vc.onBack = { [weak self] in
            self?.navigation.popViewController(animated: true)
        }
        
        navigation.pushViewController(vc, animated: true)
    }
    
    // MARK: - Private
    
    private func showProductDetails(for productId: String) {
        let details = coordinatorFactory.makeProductDetailsCoordinator(
            navigation: navigation,
            productId: productId
        )
        add(details)
        details.start()
    }
}
