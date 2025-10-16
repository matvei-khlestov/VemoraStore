//
//  UITestBootstrap.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import UIKit
import FactoryKit

#if DEBUG
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

/// Единая точка сборки root VC для UI-тестов
struct UITestBootstrap {
    private let container: Container
    
    init(container: Container = .shared) {
        self.container = container
    }
    
    /// Возвращает rootViewController для UI-теста, если среда говорит "мы в UI-тестах"
    func makeRootControllerIfNeeded(args: [String] = ProcessInfo.processInfo.arguments,
                                    env:  [String: String] = ProcessInfo.processInfo.environment) -> UIViewController? {
        let isUITests = args.contains("-uiTests") || env["START_SCREEN"] != nil
        guard isUITests else { return nil }
        
        // фабрика экранов
        let screens: ScreenFactoryProtocol = container.screenFactory()
        
        // полезные параметры из окружения
        let start = env["START_SCREEN"].flatMap(UITestStartScreen.init(rawValue:))
        let uid   = env["TEST_UID"] ?? "ui-tests-user"
        
        // собираем нужный экран
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
#endif
