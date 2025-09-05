//
//  AuthCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit
import Combine
import FactoryKit

final class AuthCoordinator: Coordinator {
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    var onFinish: (() -> Void)?
    
    private let authService: AuthServiceProtocol
    private var bag = Set<AnyCancellable>()
    
    init(
        navigation: UINavigationController,
        authService: AuthServiceProtocol = Container.shared.authService()
    ) {
        self.navigation = navigation
        self.authService = authService
    }
    
    func start() {
        let vm = Container.shared.loginViewModel()
        let vc = LoginViewController(viewModel: vm)
        
        // завершаем поток, как только авторизация стала true
        authService.isAuthorizedPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuth in
                guard isAuth else { return }
                self?.onFinish?()
            }
            .store(in: &bag)
        
        navigation.setViewControllers([vc], animated: false)
    }
}
