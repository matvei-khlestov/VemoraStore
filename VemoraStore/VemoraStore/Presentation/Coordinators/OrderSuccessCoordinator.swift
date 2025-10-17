//
//  OrderSuccessCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.09.2025.
//

import UIKit

/// Координатор `OrderSuccessCoordinator` управляет сценарием отображения экрана успешного оформления заказа.
///
/// Отвечает за:
/// - инициализацию и показ `OrderSuccessViewController`;
/// - навигацию после завершения оформления заказа;
/// - обработку событий перехода в каталог (`onOpenCatalog`);
/// - завершение сценария (`onFinish`).
///
/// Особенности:
/// - скрывает нижний таббар при отображении экрана успеха;
/// - изолирует навигацию от UI и бизнес-логики;
/// - использует `CoordinatorBuildingProtocol` для возможных переходов в другие модули.

final class OrderSuccessCoordinator: OrderSuccessCoordinatingProtocol {
    
    // MARK: - Routing
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    var onOpenCatalog: (() -> Void)?
    var onFinish: (() -> Void)?
    
    // MARK: - Factories
    
    private let coordinatorFactory: CoordinatorBuildingProtocol
    
    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        coordinatorFactory: CoordinatorBuildingProtocol
    ) {
        self.navigation = navigation
        self.coordinatorFactory = coordinatorFactory
    }
    
    // MARK: - Start
    
    func start() {
        DispatchQueue.main.async {
            let vc = OrderSuccessViewController()
            vc.hidesBottomBarWhenPushed = true
            vc.onViewCatalog = { [weak self] in self?.onOpenCatalog?() }
            self.navigation.pushViewController(vc, animated: true)
        }
    }
}
