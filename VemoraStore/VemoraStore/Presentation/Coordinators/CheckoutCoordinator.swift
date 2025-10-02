//
//  CheckoutCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 31.08.2025.
//

import UIKit

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
    
    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        viewModelFactory: ViewModelBuildingProtocol,
        coordinatorFactory: CoordinatorBuildingProtocol,
        phoneFormatter: PhoneFormattingProtocol
    ) {
        self.navigation = navigation
        self.viewModelFactory = viewModelFactory
        self.coordinatorFactory = coordinatorFactory
        self.phoneFormatter = phoneFormatter
    }
    
    // MARK: - Start
    
    func start() {
        let vm = viewModelFactory.makeCheckoutViewModel()
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
