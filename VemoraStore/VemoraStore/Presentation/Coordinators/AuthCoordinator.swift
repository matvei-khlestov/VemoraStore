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

            showAuthContainer()
        }

        private func showAuthContainer(start mode: AuthContainerViewController.Mode = .signIn) {
            let signInVM = Container.shared.signInViewModel()
            let signUpVM = Container.shared.signUpViewModel()

            let signInVC = SignInViewController(viewModel: signInVM)
            let signUpVC = SignUpViewController(viewModel: signUpVM)

            let container = AuthContainerViewController(signIn: signInVC, signUp: signUpVC, start: mode)
            container.hidesBottomBarWhenPushed = true
            container.onFinish = { [weak self] in
                self?.navigation.popViewController(animated: true)
            }

            // Переход к политике конфиденциальности
            container.onOpenPrivacy = { [weak self] in
                self?.openPrivacy()
            }

            // Переход «Забыли пароль?» (временная заглушка — метод откроем позже)
            container.onForgotPassword = {  [weak self] in
                self?.openResetPassword()
            }

            navigation.pushViewController(container, animated: true)
        }
    
   private func openPrivacy() {
        let coordinator = PrivacyPolicyCoordinator(navigation: navigation)
        add(coordinator)
        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            self.remove(coordinator)
        }
        coordinator.start()
    }
    
    private func openResetPassword() {
        let coordinator = ResetPasswordCoordinator(navigation: navigation)
        add(coordinator)
        coordinator.onFinish = { [weak self, weak coordinator] in
            guard let self, let coordinator else { return }
            self.remove(coordinator)
        }
        coordinator.start()
    }
}
