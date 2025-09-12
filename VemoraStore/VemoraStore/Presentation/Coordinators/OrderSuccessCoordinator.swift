//
//  OrderSuccessCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.09.2025.
//

import UIKit

final class OrderSuccessCoordinator: Coordinator {

    // MARK: - Routing
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []

    /// Идентификатор созданного заказа (если есть — пригодится для открытия деталей)
    private let orderId: String?

    /// Внешний колбэк: что делать по нажатию «Открыть заказ»
    /// Пробрасываем наверх, чтобы родитель (например, App/Root/OrdersCoordinator) решал куда вести.
    var onOpenOrder: ((String?) -> Void)?

    /// Когда экран закрыли (если нужно отреагировать снаружи)
    var onFinish: (() -> Void)?

    // MARK: - Init
    init(navigation: UINavigationController, orderId: String? = nil) {
        self.navigation = navigation
        self.orderId = orderId
    }

    // MARK: - Start
    func start() {
        let vc = OrderSuccessViewController()
        vc.onViewOrder = { [weak self] in
            guard let self else { return }
            self.onOpenOrder?(self.orderId)
        }
        navigation.pushViewController(vc, animated: true)
    }

    // Если нужно программно завершить координатор
    func finish() {
        onFinish?()
    }
}
