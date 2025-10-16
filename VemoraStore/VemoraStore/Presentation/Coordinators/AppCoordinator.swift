//
//  AppCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit

/// Координатор верхнего уровня, управляющий основным потоком приложения.
///
/// `AppCoordinator` определяет точку входа и отвечает за выбор стартового флоу
/// — авторизацию или главный экран — в зависимости от состояния пользователя.
/// Он также обрабатывает переходы между модулями (авторизация, основной экран,
/// успешное оформление заказа, удаление аккаунта и т.д.).
///
/// ## Основные обязанности:
/// - Запуск инициализации сессии (`SessionManaging`).
/// - Определение стартового состояния приложения (авторизован / не авторизован).
/// - Управление навигацией между Auth, Main и OrderSuccess координаторами.
/// - Очистка дочерних координаторов после завершения их работы.
///
/// Использует фабрику координаторов (`CoordinatorBuildingProtocol`) для создания
/// конкретных флоу и обеспечивает слабую связанность между модулями.

final class AppCoordinator: AppCoordinatingProtocol {
    
    // MARK: - Deps
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let authService: AuthServiceProtocol
    private let coordinatorFactory: CoordinatorBuildingProtocol
    private let sessionManager: SessionManaging
    
    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        authService: AuthServiceProtocol,
        coordinatorFactory: CoordinatorBuildingProtocol,
        sessionManager: SessionManaging
    ) {
        self.navigation = navigation
        self.authService = authService
        self.coordinatorFactory = coordinatorFactory
        self.sessionManager = sessionManager
        
        sessionManager.start()
    }
    
    // MARK: - Start
    
    func start() {
        if authService.currentUserId != nil {
            showMain()
        } else {
            showAuth()
        }
    }
    
    // MARK: - Public helper
    
    func requireAuth(completion: @escaping () -> Void) {
        if authService.currentUserId != nil {
            completion()
            return
        }
        showAuth(onFinish: completion)
    }
    
    // MARK: - Flows
    
    private func showAuth(onFinish: (() -> Void)? = nil) {
        navigation.setNavigationBarHidden(false, animated: false)
        
        let auth = coordinatorFactory.makeAuthCoordinator(navigation: navigation)
        add(auth)
        
        auth.onFinish = { [weak self, weak auth] in
            guard let self else { return }
            if let auth { self.remove(auth) }
            if let onFinish {
                onFinish()
            } else {
                self.showMain()
            }
        }
        
        auth.start()
    }
    
    private func showMain() {
        navigation.setNavigationBarHidden(true, animated: false)
        
        let main = coordinatorFactory.makeMainCoordinator(navigation: navigation)
        add(main)
        main.onLogout = { [weak self, weak main] in
            if let main { self?.remove(main) }
            self?.showAuth()
        }
        
        main.onDeleteAccount = { [weak self, weak main] in
            if let main { self?.remove(main) }
            self?.showAuth()
        }
        
        main.onOrderSuccess = { [weak self, weak main] in
            guard let self else { return }
            if let main { self.remove(main) }
            
            self.showOrderSuccess()
        }
        main.start()
    }
    
    private func showOrderSuccess() {
        let success = coordinatorFactory.makeOrderSuccessCoordinator(
            navigation: navigation
        )
        add(success)
        
        success.onOpenCatalog = { [weak self, weak success] in
            guard let self else { return }
            if let success {
                self.remove(success)
            }
            self.showMain()
        }
        
        success.onFinish = { [weak self, weak success] in
            if let success {
                self?.remove(success)
            }
        }
        
        success.start()
    }
    
#if DEBUG
    private func showDebugImport() {
        let debug = coordinatorFactory.makeDebugCoordinator(navigation: navigation)
        add(debug)
        debug.onFinish = { [weak self, weak debug] in
            if let debug { self?.remove(debug) }
        }
        debug.start()
    }
#endif
}
