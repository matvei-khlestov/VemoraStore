//
//  BrandedButton.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.09.2025.
//

import UIKit

/// Компонент `BrandedButton`.
///
/// Отвечает за:
/// - единый бренд-стиль кнопок в приложении;
/// - управление цветами и состояниями (normal/disabled);
/// - вариант с тенью для акцентных CTA;
/// - вариант submit с особыми disabled-цветами;
/// - вариант logout с иконкой.
///
/// Структура и поведение:
/// - базируется на `UIButton.Configuration.filled()`
///   с крупными скруглениями и фиксированной высотой;
/// - использует `configurationUpdateHandler`
///   для реактивного обновления цветов;
/// - для стиля с тенью настраивает `CALayer`
///   (opacity, radius, offset, shadowPath).
///
/// Публичный API:
/// - `init(style:title:)` — инициализация с нужным стилем;
/// - `Style` — перечисление вариантов оформления.
///
/// Используется:
/// - на экранах авторизации, профиля, корзины и оформления заказа;
/// - как основная кнопка действия и как сабмит-кнопка.
///
/// Замечания:
/// - высота фиксирована, внутренние отступы заданы конфигурацией;
/// - для стиля с тенью задаётся `shadowPath` в `layoutSubviews()`.

final class BrandedButton: UIButton {
    
    enum Style {
        /// Фирменная кнопка без теней
        case primary
        /// Фирменная кнопка с тенью (для Checkout, Cart и т.п.)
        case primaryWithShadow
        /// Сабмит-кнопка с особым disabled-состоянием
        case submit
        /// Кнопка выхода (с иконкой и кастомными инсетами)
        case logout(icon: String)
    }
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Sizes {
            static let height: CGFloat = 50
        }
        
        enum Insets {
            static let content = NSDirectionalEdgeInsets(
                top: 14, leading: 16, bottom: 14, trailing: 16
            )
            static let logoutContent = NSDirectionalEdgeInsets(
                top: 12, leading: 16, bottom: 12, trailing: 16
            )
        }
        
        enum Shadows {
            static let opacity: Float = 0.5
            static let radius: CGFloat = 8
            static let offset = CGSize(width: 0, height: 4)
        }
    }
    
    // MARK: - Colors
    
    private enum Colors {
        static let normalBG: UIColor = .brightPurple
        static let normalFG: UIColor = .white
        static let disabledBG: UIColor = UIColor.brightPurple.withAlphaComponent(0.65)
        static let disabledFG: UIColor = UIColor.white.withAlphaComponent(0.9)
    }
    
    // MARK: - State
    
    private let style: Style
    
    // MARK: - Init
    
    init(style: Style, title: String) {
        self.style = style
        super.init(frame: .zero)
        setupBaseConfiguration(title: title)
        applyStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension BrandedButton {
    func setupBaseConfiguration(title: String) {
        var cfg = UIButton.Configuration.filled()
        cfg.title = title
        cfg.baseBackgroundColor = Colors.normalBG
        cfg.baseForegroundColor = Colors.normalFG
        cfg.cornerStyle = .large
        cfg.contentInsets = Metrics.Insets.content
        configuration = cfg
        
        layer.cornerCurve = .continuous
        heightAnchor.constraint(equalToConstant: Metrics.Sizes.height).isActive = true
    }
    
    func applyStyle() {
        switch style {
        case .primary:
            setupPrimaryColorUpdates()
            
        case .primaryWithShadow:
            setupPrimaryColorUpdates()
            layer.masksToBounds = false
            layer.shadowOpacity = Metrics.Shadows.opacity
            layer.shadowRadius = Metrics.Shadows.radius
            layer.shadowOffset = Metrics.Shadows.offset
            
        case .submit:
            setupSubmitColorUpdates()
            
        case .logout(let iconName):
            setupLogoutStyle(iconName: iconName)
        }
    }
    
    /// Унифицированные обновления цветов для primary / primaryWithShadow
    func setupPrimaryColorUpdates() {
        configurationUpdateHandler = { [weak self] button in
            guard self != nil, var conf = button.configuration else { return }
            conf.background.backgroundColorTransformer = UIConfigurationColorTransformer { _ in
                Colors.normalBG
            }
            conf.baseForegroundColor = Colors.normalFG
            button.configuration = conf
        }
    }
    
    /// Особое disabled-состояние для сабмита
    func setupSubmitColorUpdates() {
        configurationUpdateHandler = { button in
            guard var conf = button.configuration else { return }
            let isEnabled = button.isEnabled
            
            let bg = isEnabled ? Colors.normalBG : Colors.disabledBG
            let fg = isEnabled ? Colors.normalFG : Colors.disabledFG
            
            conf.background.backgroundColorTransformer = UIConfigurationColorTransformer { _ in bg }
            conf.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var out = incoming
                out.foregroundColor = fg
                return out
            }
            conf.baseForegroundColor = fg
            
            button.configuration = conf
        }
    }
    
    /// Стиль для logout-кнопки
    func setupLogoutStyle(iconName: String) {
        guard var conf = configuration else { return }
        conf.baseBackgroundColor = Colors.normalBG
        conf.baseForegroundColor = Colors.normalFG
        conf.cornerStyle = .large
        conf.image = UIImage(systemName: iconName)
        conf.imagePadding = 10
        conf.contentInsets = Metrics.Insets.logoutContent
        configuration = conf
    }
}

// MARK: - Layout

extension BrandedButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        if case .primaryWithShadow = style {
            layer.shadowPath = UIBezierPath(
                roundedRect: bounds,
                cornerRadius: layer.cornerRadius
            ).cgPath
        }
    }
}
