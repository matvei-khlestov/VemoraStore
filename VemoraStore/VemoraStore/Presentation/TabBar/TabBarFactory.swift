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
        root.navigationItem.largeTitleDisplayMode = .always
        root.navigationItem.title = tab.title
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
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 12)
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.brightPurple,
            .font: UIFont.systemFont(ofSize: 12)
        ]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.brightPurple
        
        tabBarController.tabBar.standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            tabBarController.tabBar.scrollEdgeAppearance = appearance
        }
    }
}

