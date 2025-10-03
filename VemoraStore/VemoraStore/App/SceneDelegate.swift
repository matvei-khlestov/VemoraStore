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
        window = UIWindow(windowScene: windowScene)
        let nav = UINavigationController()
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        
        let factory = CompositionRoot.makeCoordinatorFactory()
        let coordinator = factory.makeAppCoordinator(navigation: nav)
        self.appCoordinator = coordinator
        coordinator.start()
    }
}

