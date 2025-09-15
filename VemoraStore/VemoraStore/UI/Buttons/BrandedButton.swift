//
//  BrandedButton.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.09.2025.
//

import UIKit

enum BrandedButton {
    enum Style {
        /// Фирменная кнопка без теней
        case primary
        /// Фирменная кнопка с тенью (для Checkout, Cart и т.п.)
        case primaryWithShadow
    }

    /// Создаёт кнопку с заданным стилем
    static func make(_ style: Style, title: String) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.baseBackgroundColor = .brightPurple
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .large

        let button = UIButton(configuration: configuration, primaryAction: nil)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerCurve = .continuous

        switch style {
        case .primary:
            break
        case .primaryWithShadow:
            button.layer.masksToBounds = false
            button.layer.shadowOpacity = 0.5
            button.layer.shadowRadius = 8
            button.layer.shadowOffset = CGSize(width: 0, height: 4)
        }

        return button
    }
}
