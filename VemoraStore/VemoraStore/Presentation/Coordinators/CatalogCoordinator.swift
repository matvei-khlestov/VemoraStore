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
    
    // MARK: - State
    
    private var catalogVM: CatalogViewModelProtocol?
    
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
        self.catalogVM = vm
        let vc = CatalogViewController(viewModel: vm)

        // Навигация
        vc.onSelectProduct = { [weak self] product in
            self?.showProductDetails(for: product.id)
        }
        vc.onSelectCategory = { [weak self] category in
            self?.showCategoryProducts(for: category)
        }
        vc.onFilterTap = { [weak self] state in
            self?.showFilter(initialState: state)
        }

        navigation.setViewControllers([vc], animated: false)
    }
    
    // MARK: - Private
    
    private func showProductDetails(for productId: String) {
        let detailsCoordinator = coordinatorFactory.makeProductDetailsCoordinator(
            navigation: navigation,
            productId: productId
        )
        add(detailsCoordinator)
        detailsCoordinator.start()
    }
    
    private func showCategoryProducts(for category: Category) {
        let categoryCoordinator = coordinatorFactory.makeCategoryProductsCoordinator(
            navigation: navigation,
            categoryId: category.id,
            categoryTitle: category.name
        )
        add(categoryCoordinator)
        categoryCoordinator.start()
    }
    
    private func showFilter(initialState: FilterState) {
        let filterCoordinator = coordinatorFactory.makeCatalogFilterCoordinator(
            navigation: navigation,
            initialState: initialState
        )
        add(filterCoordinator)
        
        filterCoordinator.onFinish = { [weak self, weak filterCoordinator] appliedState in
            guard let self else { return }
            
            if let applied = appliedState {
                self.catalogVM?.applyFilters(applied)
            }
            if let coord = filterCoordinator {
                self.remove(coord)
            }
        }
        
        filterCoordinator.start()
    }
}
