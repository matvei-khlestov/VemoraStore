//
//  UIViewController+NavBar.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 17.09.2025.
//

import UIKit

extension UIViewController {
    func setupNavigationBar(title: String = "",
                            largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode = .always,
                            prefersLargeTitles: Bool = true) {
        self.title = title
        navigationItem.largeTitleDisplayMode = largeTitleDisplayMode
        navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
    }
    
    func setupNavigationBarWithNavLeftItem(title: String = "",
                                       tintColor: UIColor = .brightPurple,
                                       action: Selector,
                                       largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode = .always,
                                       prefersLargeTitles: Bool = true) {
        
        setupNavigationBar(title: title,
                           largeTitleDisplayMode: largeTitleDisplayMode,
                           prefersLargeTitles: prefersLargeTitles)
        
        navigationItem.leftBarButtonItem = .backItem(
            target: self,
            action: action,
            tintColor: tintColor
        )
    }
}
