//
//  SceneDelegate.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinatingProtocol?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // работает только в DEBUG
//        #if DEBUG
//        if let uiTestRoot = UITestRoot.makeRootController() {
//            window.rootViewController = uiTestRoot
//            window.makeKeyAndVisible()
//            return
//        }
//        #endif

        // Обычный продовый запуск
        let nav = UINavigationController()
        window.rootViewController = nav
        window.makeKeyAndVisible()

        let factory = CompositionRoot.makeCoordinatorFactory()
        let coordinator = factory.makeAppCoordinator(navigation: nav)
        self.appCoordinator = coordinator
        coordinator.start()
    }
}

