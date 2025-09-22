//
//  MainCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit
import FactoryKit

final class MainCoordinator: Coordinator {
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    var onLogout: (() -> Void)?
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }
    
    func start() {
        
        let catalogVC = CatalogViewController()
        let catalogNav = TabBarFactory.makeNav(root: catalogVC, tab: .catalog)
        let catalog = CatalogCoordinator(navigation: catalogNav)
        add(catalog)
        catalog.start()
        
        let favoritesVC = FavoritesViewController()
        let favoritesNav = TabBarFactory.makeNav(root: favoritesVC, tab: .favorites)
        let favorites = FavoritesCoordinator(navigation: favoritesNav)
        add(favorites)
        favorites.start()
        
        let cartVC = CartViewController()
        let cartNav = TabBarFactory.makeNav(root: cartVC, tab: .cart)
        let cart = CartCoordinator(navigation: cartNav)
        add(cart)
        cart.start()
        
        let profileUserVM = Container.shared.profileUserViewModel()
        let profileVC = ProfileUserViewController(viewModel: profileUserVM)
        let profileNav = TabBarFactory.makeNav(root: profileVC, tab: .profile)
        let profile = ProfileUserCoordinator(navigation: profileNav)
        add(profile)
        profile.start()
        
        let tab = TabBarFactory.makeTabBar(
            viewControllers: [catalogNav, favoritesNav, cartNav, profileNav],
            selected: .catalog
        )
        
        navigation.setViewControllers([tab], animated: true)
    }
}
