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
        applyRightTextButton(title: rightTitle, action: rightAction, tintColor: tintColor)
    }

    func setupNavigationBarWithRightItem(
        title: String = "",
        tintColor: UIColor = .brightPurple,
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
        applyRightTextButton(title: rightTitle, action: rightAction, tintColor: tintColor)
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

    func applyRightTextButton(title: String?, action: Selector?, tintColor: UIColor) {
        guard let title, let action else {
            navigationItem.rightBarButtonItem = nil
            return
        }
        let button = UIBarButtonItem(
            title: title,
            style: .plain,
            target: self,
            action: action
        )
        button.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 17, weight: .medium),
            .foregroundColor: tintColor
        ], for: .normal)
        navigationItem.rightBarButtonItem = button
    }
}
