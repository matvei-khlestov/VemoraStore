//
//  TabBarFactory.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit

struct TabBarFactory {

    static func makeNav(root: UIViewController, tab: AppTab) -> UINavigationController {
        let nav = UINavigationController(rootViewController: root)
        nav.navigationBar.prefersLargeTitles = true
        nav.tabBarItem = UITabBarItem(title: tab.title,
                                      image: UIImage(systemName: tab.systemImage),
                                      tag: tab.rawValue)
        return nav
    }

    static func makeTabBar(viewControllers: [UIViewController], selected: AppTab = .catalog) -> UITabBarController {
        let tab = UITabBarController()
        tab.viewControllers = viewControllers
        tab.selectedIndex = selected.rawValue
        applyAppearance(to: tab)
        return tab
    }

    static func applyAppearance(to tabBarController: UITabBarController) {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBarController.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBarController.tabBar.scrollEdgeAppearance = appearance
        }
    }
}

