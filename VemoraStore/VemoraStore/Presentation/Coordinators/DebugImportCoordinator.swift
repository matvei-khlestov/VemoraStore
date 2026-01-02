//
//  DebugImportCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 27.09.2025.
//

import UIKit

#if DEBUG
final class DebugImportCoordinator: DebugCoordinatingProtocol {
    
    // MARK: - Deps
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    private let viewModelFactory: ViewModelBuildingProtocol
    var onFinish: (() -> Void)?
    
    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        viewModelFactory: ViewModelBuildingProtocol
    ) {
        self.navigation = navigation
        self.viewModelFactory = viewModelFactory
    }
    
    // MARK: - Start
    
    func start() {
        let vm = viewModelFactory.makeDebugImortViewModel()
        let vc = DebugImportViewController(viewModel: vm)
        vc.hidesBottomBarWhenPushed = true
        navigation.pushViewController(vc, animated: true)
    }
}
#endif
