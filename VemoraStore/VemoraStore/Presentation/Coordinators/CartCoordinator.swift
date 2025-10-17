//
//  CartCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 31.08.2025.
//

import UIKit

/// Координатор `CartCoordinator` управляет сценарием отображения экрана корзины.
///
/// Отвечает за:
/// - инициализацию и показ `CartViewController`;
/// - навигацию к оформлению заказа (`CheckoutCoordinator`);
/// - переход к карточке товара (`ProductDetailsCoordinator`);
/// - завершение сценария оформления заказа через `onOrderSuccess`.
///
/// Особенности:
/// - скрывает детали реализации навигации от слоя View и ViewModel;
/// - использует фабрики для построения зависимостей и подкоординаторов;
/// - соблюдает принципы архитектуры Coordinator, обеспечивая модульность и читаемость навигации.

final class CartCoordinator: CartCoordinatingProtocol {
    
    // MARK: - Props
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    var onOrderSuccess: (() -> Void)?
    
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
        let vm = viewModelFactory.makeCartViewModel(userId: userId)
        let vc = CartViewController(viewModel: vm)
        
        vc.onCheckout = { [weak self] in
            self?.showCheckout()
        }
        
        vc.onSelectProductId = { [weak self] productId in
            self?.showProductDetails(for: productId)
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
    
    private func showProductDetails(for productId: String) {
        let details = coordinatorFactory.makeProductDetailsCoordinator(
            navigation: navigation,
            productId: productId
        )
        add(details)
        details.start()
    }
}
