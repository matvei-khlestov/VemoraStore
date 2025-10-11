//
//  CategoryProductsCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 07.10.2025.
//

import UIKit

final class CategoryProductsCoordinator: CategoryProductsCoordinatingProtocol {

    // MARK: - Properties

    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []

    // MARK: - Factories

    private let viewModelFactory: ViewModelBuildingProtocol
    private let coordinatorFactory: CoordinatorBuildingProtocol

    // MARK: - Input

    private let categoryId: String
    private let categoryTitle: String

    // MARK: - Init

    init(
        navigation: UINavigationController,
        viewModelFactory: ViewModelBuildingProtocol,
        coordinatorFactory: CoordinatorBuildingProtocol,
        categoryId: String,
        categoryTitle: String
    ) {
        self.navigation = navigation
        self.viewModelFactory = viewModelFactory
        self.coordinatorFactory = coordinatorFactory
        self.categoryId = categoryId
        self.categoryTitle = categoryTitle
    }

    // MARK: - Start

    func start() {
        let vm = viewModelFactory.makeCategoryProductsViewModel(categoryId: categoryId)
        let vc = CategoryProductsViewController(viewModel: vm)

        vc.title = categoryTitle

        // Колбэки
        vc.onSelectProduct = { [weak self] product in
            self?.showProductDetails(for: product)
        }
        vc.onBack = { [weak self] in
            self?.navigation.popViewController(animated: true)
        }

        navigation.pushViewController(vc, animated: true)
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
}
