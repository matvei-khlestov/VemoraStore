//
//  CatalogFilterCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 09.10.2025.
//

import UIKit

final class CatalogFilterCoordinator: CatalogFilterCoordinatingProtocol {
    
    // MARK: - Properties
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    let initialState: FilterState
    var onFinish: ((FilterState?) -> Void)?
    
    private let viewModelFactory: ViewModelBuildingProtocol
    
    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        initialState: FilterState,
        viewModelFactory: ViewModelBuildingProtocol
    ) {
        self.navigation = navigation
        self.initialState = initialState
        self.viewModelFactory = viewModelFactory
    }
    
    // MARK: - Start
    
    func start() {
        let vm = viewModelFactory.makeCatalogFilterViewModel()
        let vc = CatalogFilterViewController(viewModel: vm, initialState: initialState)
        vc.hidesBottomBarWhenPushed = true
        
        vc.onBack = { [weak self] in
            guard let self else { return }
            self.onFinish?(nil)
            self.navigation.popViewController(animated: true)
        }
        
        vc.onApply = { [weak self] appliedState in
            guard let self else { return }
            self.onFinish?(appliedState)
            self.navigation.popViewController(animated: true)
        }
        
        navigation.pushViewController(vc, animated: true)
    }
}
