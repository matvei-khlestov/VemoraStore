//
//  UIViewController+NavBar.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 17.09.2025.
//

import UIKit

extension UIViewController {
    
    // MARK: - Public API
    
    func setupNavigationBar(
        title: String = "",
        largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode = .always,
        prefersLargeTitles: Bool = true
    ) {
        self.title = title
        navigationItem.largeTitleDisplayMode = largeTitleDisplayMode
        navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
    }

    func setupNavigationBarWithNavLeftItem(
        title: String = "",
        tintColor: UIColor = .brightPurple,
        action: Selector,
        largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode = .always,
        prefersLargeTitles: Bool = true
    ) {
        setupNavigationBar(
            title: title,
            largeTitleDisplayMode: largeTitleDisplayMode,
            prefersLargeTitles: prefersLargeTitles
        )
        applyLeftBackButton(tintColor: tintColor, action: action)
        navigationItem.rightBarButtonItem = nil
    }

    func setupNavigationBarWithNavItems(
        title: String = "",
        tintColor: UIColor = .brightPurple,
        leftAction: Selector,
        rightTitle: String? = nil,
        rightAction: Selector? = nil,
        largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode = .always,
        prefersLargeTitles: Bool = true
    ) {
        setupNavigationBar(
            title: title,
            largeTitleDisplayMode: largeTitleDisplayMode,
            prefersLargeTitles: prefersLargeTitles
        )
        applyLeftBackButton(tintColor: tintColor, action: leftAction)
        applyRightTextButton(title: rightTitle, action: rightAction)
    }

    func setupNavigationBarWithRightItem(
        title: String = "",
        rightTitle: String? = nil,
        rightAction: Selector? = nil,
        largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode = .always,
        prefersLargeTitles: Bool = true
    ) {
        setupNavigationBar(
            title: title,
            largeTitleDisplayMode: largeTitleDisplayMode,
            prefersLargeTitles: prefersLargeTitles
        )
        navigationItem.leftBarButtonItem = nil
        applyRightTextButton(title: rightTitle, action: rightAction)
    }
}

// MARK: - Private helpers

private extension UIViewController {
    func applyLeftBackButton(tintColor: UIColor, action: Selector) {
        navigationItem.leftBarButtonItem = .backItem(
            target: self,
            action: action,
            tintColor: tintColor
        )
    }

    func applyRightTextButton(title: String?, action: Selector?) {
        guard let title, let action else {
            navigationItem.rightBarButtonItem = nil
            return
        }

        if title.lowercased().contains("очистить") {
            navigationItem.rightBarButtonItem = .brandedClear(
                title: title,
                target: self,
                action: action
            )
        } else {
            navigationItem.rightBarButtonItem = .brandedText(
                title: title,
                target: self,
                action: action
            )
        }
    }
}
