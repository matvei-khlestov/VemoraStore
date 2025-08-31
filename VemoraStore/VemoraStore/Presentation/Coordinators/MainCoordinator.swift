//
//  MainCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit

final class MainCoordinator: Coordinator {
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    var onLogout: (() -> Void)?
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }
    
    func start() {
        
        let catalogNav = UINavigationController()
        let catalog = CatalogCoordinator(navigation: catalogNav)
        store(catalog)
        catalog.start()
        
        let favoritesNav = UINavigationController()
        let favorites = FavoritesCoordinator(navigation: favoritesNav)
        store(favorites)
        favorites.start()
        
        let cartNav = UINavigationController()
        let cart = CartCoordinator(navigation: cartNav)
        store(cart); cart.start()
        
        let profileNav = UINavigationController()
        let profile = ProfileCoordinator(navigation: profileNav)
        store(profile)
        profile.onLogout = { [weak self] in self?.onLogout?() }
        profile.start()
        
        catalogNav.tabBarItem   = UITabBarItem(title: AppTab.catalog.title,   image: UIImage(systemName: AppTab.catalog.systemImage),   tag: AppTab.catalog.rawValue)
        favoritesNav.tabBarItem = UITabBarItem(title: AppTab.favorites.title, image: UIImage(systemName: AppTab.favorites.systemImage), tag: AppTab.favorites.rawValue)
        cartNav.tabBarItem      = UITabBarItem(title: AppTab.cart.title,      image: UIImage(systemName: AppTab.cart.systemImage),      tag: AppTab.cart.rawValue)
        profileNav.tabBarItem   = UITabBarItem(title: AppTab.profile.title,   image: UIImage(systemName: AppTab.profile.systemImage),   tag: AppTab.profile.rawValue)
        
        let tab = TabBarFactory.makeTabBar(
            viewControllers: [catalogNav, favoritesNav, cartNav, profileNav],
            selected: .catalog
        )
        
        navigation.setViewControllers([tab], animated: true)
    }
}
