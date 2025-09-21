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
        authService: AuthServiceProtocol
    ) {
        self.navigation = navigation
        self.authService = authService
    }
    
    func start() {
        authService.isAuthorizedPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] isAuthorized in
                guard let self else { return }
                if isAuthorized { self.onFinish?() }
            }
            .store(in: &bag)
        
        showSignUp()
    }
    
    private func showSignUp() {
        let vm = Container.shared.signUpViewModel()
        let vc = SignUpViewController(viewModel: vm)
        vc.hidesBottomBarWhenPushed = true
        
        vc.onBack = { [weak self] in
            self?.navigation.popViewController(animated: true)
            self?.onFinish?()
        }
        
        vc.onOpenPrivacy = { [weak self] in
            self?.openPrivacy()
        }
        
        vc.onLogin = { [weak self] in
            self?.showLogin()
        }
        
        navigation.pushViewController(vc, animated: true)
    }
    
    private func showLogin() {
        //            let vm = Container.shared.signInViewModel()
        //            let vc = SignInViewController(viewModel: vm)
        //            vc.hidesBottomBarWhenPushed = true
        //
        //            vc.onBack = { [weak self] in
        //                self?.navigation.popViewController(animated: true)
        //            }
        //
        //            navigation.pushViewController(vc, animated: true)
    }
    
    func openPrivacy() {
        let coordinator = PrivacyPolicyCoordinator(navigation: navigation)
        add(coordinator)
        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            self.remove(coordinator)
        }
        coordinator.start()
    }
}
