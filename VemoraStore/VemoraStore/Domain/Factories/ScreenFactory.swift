//
//  ScreenFactory.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import UIKit
import FactoryKit

/// Класс `ScreenFactory`
///
/// Отвечает за сборку и инициализацию экранов (ViewController) приложения.
/// Использует зависимости из DI-контейнера `FactoryKit.Container`, создавая
/// соответствующие ViewModel и связывая их с контроллерами.
///
/// Основные задачи:
/// - централизованное создание экранов без дублирования логики;
/// - упрощение UI-тестирования (все сборки экранов выполняются через единый интерфейс);
/// - поддержка строгой типизации и явного внедрения зависимостей.
///
/// Используется в:
/// - UI-тестах, где требуется создать конкретный экран без запуска всего приложения.

final class ScreenFactory: ScreenFactoryProtocol {
    
    private let container: Container
    
    init(container: Container) {
        self.container = container
    }
    
    // MARK: SignIn
    
    func makeSignInViewController() -> UIViewController {
        let viewModel: SignInViewModelProtocol = container.signInViewModel()
        let vc = SignInViewController(viewModel: viewModel)
        _ = vc.view
        return vc
    }
    
    // MARK: SignUp
    
    func makeSignUpViewController() -> UIViewController {
        let viewModel: SignUpViewModelProtocol = container.signUpViewModel()
        let vc = SignUpViewController(viewModel: viewModel)
        _ = vc.view
        return vc
    }
    
    // MARK: Profile
    
    func makeProfileUserViewController(userId: String) -> UIViewController {
        let vm: ProfileUserViewModelProtocol = container.profileUserViewModel(userId)
        let vc = ProfileUserViewController(viewModel: vm)
        _ = vc.view
        return vc
    }
    
    // MARK: Edit Profile
    
    func makeEditProfileViewController(userId: String) -> UIViewController {
        let vm: EditProfileViewModelProtocol = container.editProfileViewModel(userId)
        let vc = EditProfileViewController(viewModel: vm)
        _ = vc.view
        return vc
    }
    
    // MARK: Edit Name / Email / Phone (BaseEditField)
    
    func makeEditNameViewController(userId: String) -> UIViewController {
        let vm: EditNameViewModelProtocol = container.editNameViewModel(userId)
        let base = BaseEditFieldViewController(
            viewModel: vm,
            fieldKind: .name,
            navTitle: "Изменение имени"
        )
        _ = base.view
        return base
    }
    
    func makeEditEmailViewController(userId: String) -> UIViewController {
        let vm: EditEmailViewModelProtocol = container.editEmailViewModel(userId)
        let base = BaseEditFieldViewController(
            viewModel: vm,
            fieldKind: .email,
            navTitle: "Изменение email"
        )
        _ = base.view
        return base
    }
    
    func makeEditPhoneViewController(userId: String) -> UIViewController {
        let vm: EditPhoneViewModelProtocol = container.editPhoneViewModel(userId)
        let base = BaseEditFieldViewController(
            viewModel: vm,
            fieldKind: .phone,
            navTitle: "Изменение телефона",
            phoneFormatter: container.phoneFormatter()
        )
        _ = base.view
        return base
    }
}
