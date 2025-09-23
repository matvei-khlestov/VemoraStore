//
//  AuthCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit
import Combine

final class AuthCoordinator: AuthCoordinatingProtocol {
    
    // MARK: - Deps
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let authService: AuthServiceProtocol
    private let viewModelFactory: ViewModelBuildingProtocol
    private let coordinatorFactory: CoordinatorBuildingProtocol
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Callbacks
    
    var onFinish: (() -> Void)?
    
    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        authService: AuthServiceProtocol,
        viewModelFactory: ViewModelBuildingProtocol,
        coordinatorFactory: CoordinatorBuildingProtocol
    ) {
        self.navigation = navigation
        self.authService = authService
        self.viewModelFactory = viewModelFactory
        self.coordinatorFactory = coordinatorFactory
    }
    
    // MARK: - Start
    
    func start() {
        authService.isAuthorizedPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] isAuthorized in
                guard let self else { return }
                if isAuthorized { self.onFinish?() }
            }
            .store(in: &bag)

        showAuthContainer()
    }

    // MARK: - Flow
    
    private func showAuthContainer(start mode: AuthContainerViewController.Mode = .signIn) {
        let signInVM = viewModelFactory.makeSignInViewModel()
        let signUpVM = viewModelFactory.makeSignUpViewModel()

        let signInVC = SignInViewController(viewModel: signInVM)
        let signUpVC = SignUpViewController(viewModel: signUpVM)

        let container = AuthContainerViewController(
            signIn: signInVC,
            signUp: signUpVC,
            start: mode
        )
        container.hidesBottomBarWhenPushed = true

        container.onFinish = { [weak self] in
            self?.navigation.popViewController(animated: true)
        }

        container.onOpenPrivacy = { [weak self] in
            self?.openPrivacy()
        }

        container.onForgotPassword = { [weak self] in
            self?.openResetPassword()
        }

        navigation.pushViewController(container, animated: true)
    }
    
    private func openPrivacy() {
        let coordinator = coordinatorFactory.makePrivacyPolicyCoordinator(navigation: navigation)
        add(coordinator)
        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            self.remove(coordinator)
        }
        coordinator.start()
    }
    
    private func openResetPassword() {
        let coordinator = coordinatorFactory.makeResetPasswordCoordinator(navigation: navigation)
        add(coordinator)
        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            self.remove(coordinator)
        }
        coordinator.start()
    }
}
