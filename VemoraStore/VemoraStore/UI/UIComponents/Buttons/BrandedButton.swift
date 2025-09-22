//
//  BrandedButton.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.09.2025.
//

import UIKit

final class BrandedButton: UIButton {
    enum Style {
        /// Фирменная кнопка без теней
        case primary
        /// Фирменная кнопка с тенью (для Checkout, Cart и т.п.)
        case primaryWithShadow
        /// Фирменная кнопка для сабмита (например, регистрации/логина) с особым стилем disabled-состояния
        case submit
    }
    
    private let style: Style
    
    init(style: Style, title: String) {
        self.style = style
        super.init(frame: .zero)
        configure(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(title: String) {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.baseBackgroundColor = .brightPurple
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .large
        
        self.configuration = configuration
        self.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.layer.cornerCurve = .continuous
        
        configuration.contentInsets = .init(top: 14, leading: 16, bottom: 14, trailing: 16)
        self.configuration = configuration
        
        switch style {
        case .primary:
            break
        case .primaryWithShadow:
            self.layer.masksToBounds = false
            self.layer.shadowOpacity = 0.5
            self.layer.shadowRadius = 8
            self.layer.shadowOffset = CGSize(width: 0, height: 4)
        case .submit:
            self.configurationUpdateHandler = { btn in
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
    }
}
