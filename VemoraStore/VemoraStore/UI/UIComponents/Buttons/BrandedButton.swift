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
        /// Фирменная кнопка для сабмита (например, регистрации/логина) с особым стилем disabled-состояния
        case submit
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
        
        configuration.contentInsets = .init(top: 14, leading: 16, bottom: 14, trailing: 16)
        button.configuration = configuration
        
        switch style {
        case .primary:
            break
        case .primaryWithShadow:
            button.layer.masksToBounds = false
            button.layer.shadowOpacity = 0.5
            button.layer.shadowRadius = 8
            button.layer.shadowOffset = CGSize(width: 0, height: 4)
        case .submit:
            button.configurationUpdateHandler = { btn in
                guard var conf = btn.configuration else { return }
                
                let bg: UIColor = btn.isEnabled ? .brightPurple : UIColor.brightPurple.withAlphaComponent(0.65)
                let fg: UIColor = btn.isEnabled ? .white : UIColor.white.withAlphaComponent(0.9)
                
                conf.background.backgroundColorTransformer = UIConfigurationColorTransformer { _ in bg }
                conf.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                    var out = incoming
                    out.foregroundColor = fg
                    return out
                }
                
                btn.configuration = conf
            }
        }
        
        return button
    }
}
