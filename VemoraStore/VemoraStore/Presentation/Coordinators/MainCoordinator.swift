//
//  MainCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit

final class MainCoordinator: MainCoordinatingProtocol {
    
    // MARK: - Deps
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    var onLogout: (() -> Void)?
    var onDeleteAccount: (() -> Void)?
    
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
        let catalogNav = TabBarFactory.makeNav(root: UIViewController(), tab: .catalog)
        let catalog = coordinatorFactory.makeCatalogCoordinator(navigation: catalogNav)
        add(catalog)
        catalog.start()
        
        // Favorites
        let favoritesNav = TabBarFactory.makeNav(root: UIViewController(), tab: .favorites)
        let favorites = coordinatorFactory.makeFavoritesCoordinator(navigation: favoritesNav)
        add(favorites)
        favorites.start()
        
        // Cart
        let cartNav = TabBarFactory.makeNav(root: UIViewController(), tab: .cart)
        let cart = coordinatorFactory.makeCartCoordinator(navigation: cartNav)
        add(cart)
        cart.start()
        
        // Profile (User)
        let profileNav = TabBarFactory.makeNav(root: UIViewController(), tab: .profile)
        let profile = coordinatorFactory.makeProfileUserCoordinator(navigation: profileNav)
        profile.onLogout = { [weak self] in
            self?.onLogout?()
        }
        profile.onDeleteAccount = { [weak self] in
            self?.onDeleteAccount?()
        }
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
