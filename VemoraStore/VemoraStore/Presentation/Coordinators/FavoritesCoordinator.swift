//
//  FavoritesCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 31.08.2025.
//

import UIKit

/// Координатор `FavoritesCoordinator` управляет сценарием отображения экрана "Избранное".
///
/// Отвечает за:
/// - инициализацию и показ `FavoritesViewController`;
/// - обработку выбора товара и переход к экрану деталей (`ProductDetailsCoordinator`);
/// - возможный переход к оформлению заказа (`CheckoutCoordinator`).
///
/// Особенности:
/// - скрывает навигационную логику от слоя ViewModel;
/// - использует фабрики `ViewModelBuildingProtocol` и `CoordinatorBuildingProtocol` для создания зависимостей;
/// - обеспечивает корректное добавление и удаление дочерних координаторов;
/// - следует принципам архитектуры Coordinator, сохраняя изоляцию бизнес-логики и навигации.

final class FavoritesCoordinator: FavoritesCoordinatingProtocol {

    // MARK: - Routing
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []

    // MARK: - Factories
    
    private let viewModelFactory: ViewModelBuildingProtocol
    private let coordinatorFactory: CoordinatorBuildingProtocol
    private let authService: AuthServiceProtocol

    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        viewModelFactory: ViewModelBuildingProtocol,
        coordinatorFactory: CoordinatorBuildingProtocol,
        authService: AuthServiceProtocol
    ) {
        self.navigation = navigation
        self.viewModelFactory = viewModelFactory
        self.coordinatorFactory = coordinatorFactory
        self.authService = authService
    }

    // MARK: - Start
    
    func start() {
        let userId = authService.currentUserId ?? ""
        let vm = viewModelFactory.makeFavoritesViewModel(userId: userId)
        let vc = FavoritesViewController(viewModel: vm)

        vc.onSelectProduct = { [weak self] product in
            self?.showProductDetails(for: product)
        }

        navigation.setViewControllers([vc], animated: false)
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

    private func startCheckout() {
        let checkout = coordinatorFactory.makeCheckoutCoordinator(navigation: navigation)
        add(checkout)
        checkout.onFinish = { [weak self, weak checkout] in
            if let checkout { self?.remove(checkout) }
        }
        checkout.start()
    }
}
