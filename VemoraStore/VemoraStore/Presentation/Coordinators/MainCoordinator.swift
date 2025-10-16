//
//  MainCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit

/// Координатор, управляющий основным потоком приложения после авторизации.
///
/// `MainCoordinator` отвечает за инициализацию и отображение главных разделов
/// приложения через `UITabBarController`: каталог, избранное, корзина и профиль.
/// Каждый раздел реализован как отдельный координатор, что обеспечивает слабую связанность
/// между модулями и позволяет масштабировать проект без дублирования навигационной логики.
///
/// ## Основные задачи:
/// - Создание и запуск дочерних координаторов: каталога, избранного, корзины и профиля.
/// - Управление событиями `onLogout`, `onDeleteAccount`, `onOrderSuccess`.
/// - Формирование и отображение основного таб-бара приложения.
///
/// ## Архитектурные особенности:
/// - Использует `CoordinatorBuildingProtocol` для фабричного создания дочерних координаторов.
/// - Применяет `TabBarFactory` для настройки и конфигурации вкладок.
/// - Реализует `MainCoordinatingProtocol`, предоставляя централизованное управление основным флоу.

final class MainCoordinator: MainCoordinatingProtocol {
    
    // MARK: - Deps
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    var onLogout: (() -> Void)?
    var onDeleteAccount: (() -> Void)?
    var onOrderSuccess: (() -> Void)?
    
    private let viewModelFactory: ViewModelBuildingProtocol
    private let coordinatorFactory: CoordinatorBuildingProtocol
    
    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        viewModelFactory: ViewModelBuildingProtocol,
        coordinatorFactory: CoordinatorBuildingProtocol
    ) {
        self.navigation = navigation
        self.viewModelFactory = viewModelFactory
        self.coordinatorFactory = coordinatorFactory
    }
    
    // MARK: - Start
    
    func start() {
        // Catalog
        let catalogNav = TabBarFactory.makeNav(tab: .catalog)
        let catalog = coordinatorFactory.makeCatalogCoordinator(navigation: catalogNav)
        add(catalog)
        catalog.start()
        
        // Favorites
        let favoritesNav = TabBarFactory.makeNav(tab: .favorites)
        let favorites = coordinatorFactory.makeFavoritesCoordinator(navigation: favoritesNav)
        add(favorites)
        favorites.start()
        
        // Cart
        let cartNav = TabBarFactory.makeNav(tab: .cart)
        let cart = coordinatorFactory.makeCartCoordinator(navigation: cartNav)
        cart.onOrderSuccess = { [weak self] in
            self?.onOrderSuccess?()
        }
        add(cart)
        cart.start()
        
        // Profile (User)
        let profileNav = TabBarFactory.makeNav(tab: .profile)
        let profile = coordinatorFactory.makeProfileUserCoordinator(navigation: profileNav)
        profile.onLogout = { [weak self] in self?.onLogout?() }
        profile.onDeleteAccount = { [weak self] in self?.onDeleteAccount?() }
        add(profile)
        profile.start()
        
        // Tab bar
        let tab = TabBarFactory.makeTabBar(
            viewControllers: [catalogNav, favoritesNav, cartNav, profileNav],
            selected: .catalog
        )
        navigation.setViewControllers([tab], animated: true)
    }
}
