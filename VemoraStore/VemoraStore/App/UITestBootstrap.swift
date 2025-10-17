//
//  UITestBootstrap.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import UIKit
import FactoryKit

#if DEBUG

/// Структура `UITestBootstrap` — точка входа для UI-тестов в приложении **VemoraStore**.
///
/// Назначение:
/// - Определяет, должен ли запускаться UI-тестовый режим приложения;
/// - Инициализирует стартовый экран для UI-тестов на основе аргументов и переменных окружения;
/// - Позволяет UI-тестам запускать конкретные модули (Sign In, Profile, Edit и др.) изолированно.
///
/// Основные возможности:
/// - Читает аргументы процесса (`ProcessInfo.processInfo.arguments`);
/// - Читает переменные окружения (`ProcessInfo.processInfo.environment`);
/// - Определяет значение `START_SCREEN` для выбора начального экрана;
/// - Оборачивает созданный экран в `UINavigationController` для корректного отображения.
///
/// Поддерживаемые стартовые экраны:
/// - `.signin` — экран входа в аккаунт;
/// - `.signup` — экран регистрации;
/// - `.profile` — профиль пользователя;
/// - `.editProfile`, `.editName`, `.editEmail`, `.editPhone` — экраны редактирования профиля.
///
/// Особенности:
/// - Используется только при сборке с флагом `#if DEBUG`;
/// - Поддерживает DI через `FactoryKit` для получения `ScreenFactoryProtocol`;
/// - По умолчанию создаёт тестового пользователя с `userId = "ui-tests-user"`;
/// - При отсутствии параметров среды — запускает экран входа (`SignInViewController`).
///
/// Расширение `UITestBootstrap` упрощает изолированное тестирование экранов
/// и обеспечивает надёжный входной сценарий для автоматических UI-тестов.

struct UITestBootstrap {
    private let container: Container
    
    init(container: Container = .shared) {
        self.container = container
    }
    
    func makeRootControllerIfNeeded(args: [String] = ProcessInfo.processInfo.arguments,
                                    env:  [String: String] = ProcessInfo.processInfo.environment) -> UIViewController? {
        let isUITests = args.contains("-uiTests") || env["START_SCREEN"] != nil
        guard isUITests else { return nil }
        
        let screens: ScreenFactoryProtocol = container.screenFactory()
        
        let start = env["START_SCREEN"].flatMap(UITestStartScreen.init(rawValue:))
        let uid   = env["TEST_UID"] ?? "ui-tests-user"
        
        let rootVC: UIViewController
        switch start {
        case .signin:
            rootVC = screens.makeSignInViewController()
            
        case .signup:
            rootVC = screens.makeSignUpViewController()
            
        case .profile:
            rootVC = screens.makeProfileUserViewController(userId: uid)
            
        case .editProfile:
            rootVC = screens.makeEditProfileViewController(userId: uid)
            
        case .editName:
            rootVC = screens.makeEditNameViewController(userId: uid)
            
        case .editEmail:
            rootVC = screens.makeEditEmailViewController(userId: uid)
            
        case .editPhone:
            rootVC = screens.makeEditPhoneViewController(userId: uid)
            
        case .none:
            rootVC = screens.makeSignInViewController()
        }
        
        return UINavigationController(rootViewController: rootVC)
    }
}

/// Какие экраны можно стартовать из UI-тестов
enum UITestStartScreen: String {
    case signin
    case signup
    case profile
    case editProfile
    case editName
    case editEmail
    case editPhone
}
#endif
