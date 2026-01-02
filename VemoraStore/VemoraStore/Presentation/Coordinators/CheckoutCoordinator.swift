//
//  CheckoutCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 31.08.2025.
//

import UIKit

/// Координатор `CheckoutCoordinator` управляет сценарием оформления заказа.
///
/// Отвечает за:
/// - инициализацию `CheckoutViewModel` через `ViewModelBuildingProtocol`;
/// - создание и показ экрана `CheckoutViewController`;
/// - навигацию к выбору адреса на карте через `MapPickerCoordinator`;
/// - обработку событий завершения оформления (`onOrderSuccess`) и возврата (`onFinish`).
///
/// Особенности:
/// - использует зависимости: `PhoneFormattingProtocol`, `SessionManaging`, `AuthServiceProtocol`;
/// - скрывает нижний таббар при переходе на экран оформления;
/// - изолирует навигационную логику от бизнес-логики и UI-реализации;
/// - обеспечивает передачу выбранного адреса обратно в `CheckoutViewModel`.

final class CheckoutCoordinator: CheckoutCoordinatingProtocol {
    
    // MARK: - Properties
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    var onFinish: (() -> Void)?
    var onOrderSuccess: (() -> Void)?
    
    // MARK: - Deps
    
    private let viewModelFactory: ViewModelBuildingProtocol
    private let coordinatorFactory: CoordinatorBuildingProtocol
    
    private let phoneFormatter: PhoneFormattingProtocol
    private let sessionManager: SessionManaging
    private let authService: AuthServiceProtocol
    
    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        viewModelFactory: ViewModelBuildingProtocol,
        coordinatorFactory: CoordinatorBuildingProtocol,
        phoneFormatter: PhoneFormattingProtocol,
        sessionManager: SessionManaging,
        authService: AuthServiceProtocol
    ) {
        self.navigation = navigation
        self.viewModelFactory = viewModelFactory
        self.coordinatorFactory = coordinatorFactory
        self.phoneFormatter = phoneFormatter
        self.sessionManager = sessionManager
        self.authService = authService
    }
    
    // MARK: - Start
    
    func start() {
        let cartSnapshot = sessionManager.cartItemsSnapshot
        let userId = authService.currentUserId ?? ""
        let vm = viewModelFactory.makeCheckoutViewModel(
            userId: userId,
            snapshotItems: cartSnapshot
        )
        let vc = CheckoutViewController(
            viewModel: vm,
            makePhoneSheetVM: { initialPhone in
                self.viewModelFactory.makePhoneInputSheetViewModel(
                    initialPhone: initialPhone
                )
            }, makeCommentSheetVM: { initialComment in
                self.viewModelFactory.makeCommentInputSheetViewModel(
                    initialComment: initialComment
                )
            }, phoneFormatter: phoneFormatter
        )
        
        vc.onPickOnMap = { [weak self] in
            self?.showMapPicker(viewModel: vm)
        }
        
        vc.onFinished = { [weak self] in
            self?.onOrderSuccess?()
        }
        
        vc.onBack = { [weak self] in
            self?.navigation.popViewController(animated: true)
        }
        
        navigation.pushViewController(vc, animated: true)
    }
    
    // MARK: - Private
    
    private func showMapPicker(viewModel: CheckoutViewModelProtocol) {
        let picker = coordinatorFactory.makeMapPickerCoordinator(navigation: navigation)
        picker.onFullAddressPicked = { [weak self, weak picker] fullAddress in
            guard let self else { return }
            viewModel.updateDeliveryAddress(fullAddress)
            if let picker { self.remove(picker) }
        }
        
        picker.onFinish = { [weak self, weak picker] in
            if let picker { self?.remove(picker) }
        }
        
        add(picker)
        picker.start()
    }
}
