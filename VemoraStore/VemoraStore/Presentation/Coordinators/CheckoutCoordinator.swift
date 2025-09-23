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
    
    // MARK: - Factories
    
    private let viewModelFactory: ViewModelBuildingProtocol
    private let coordinatorFactory: CoordinatorBuildingProtocol

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
        let vm = viewModelFactory.makeCheckoutViewModel()
        let vc = CheckoutViewController(
            viewModel: vm,
            makeSheetVM: { kind, initialPhone, initialComment in
                PhoneOrCommentInputSheetViewModel(
                    kind: kind,
                    initialPhone: initialPhone,
                    initialComment: initialComment
                ) as PhoneOrCommentInputSheetViewModelProtocol
            }
        )
        
        vc.onPickOnMap = { [weak self] in
            self?.showMapPicker(viewModel: vm)
        }
        vc.onFinished = { [weak self] in
            self?.showOrderSuccess()
        }
        vc.onBack = { [weak self] in
            self?.navigation.popViewController(animated: true)
        }
        
        navigation.pushViewController(vc, animated: true)
    }
    
    // MARK: - Private
    
    private func showMapPicker(viewModel: CheckoutViewModelProtocol) {
        let picker = coordinatorFactory.makeMapPickerCoordinator(navigation: navigation)
        add(picker)
        
        picker.onFullAddressPicked = { [weak self, weak picker] fullAddress in
            guard let self else { return }
            viewModel.updateDeliveryAddress(fullAddress)
            if let picker { self.remove(picker) }
        }
        
        picker.onFinish = { [weak self, weak picker] in
            if let picker { self?.remove(picker) }
        }
        
        picker.start()
    }
    
    private func showOrderSuccess() {
        let success = coordinatorFactory.makeOrderSuccessCoordinator(navigation: navigation)
        
        success.onOpenOrder = { [weak self] in
            let detailsVC = UIViewController()
            detailsVC.view.backgroundColor = .systemBackground
            self?.navigation.pushViewController(detailsVC, animated: true)
        }
        
        success.onFinish = { [weak self] in
            self?.remove(success)
        }
        
        add(success)
        success.start()
    }
}
