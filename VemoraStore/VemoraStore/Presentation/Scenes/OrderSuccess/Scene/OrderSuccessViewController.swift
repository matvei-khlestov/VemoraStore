//
//  OrderSuccessViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.09.2025.
//

import UIKit

final class OrderSuccessViewController: UIViewController {
    
    // MARK: - Callbacks
    
    var onViewCatalog: (() -> Void)?
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Spacing {
            static let stack: CGFloat = 24
            static let textStack: CGFloat = 8
        }
        
        enum Sizes {
            static let iconPointSize: CGFloat = 96
            static let buttonMinHeight: CGFloat = 44
        }
        
        enum Fonts {
            static let title: UIFont    = .systemFont(ofSize: 28, weight: .bold)
            static let subtitle: UIFont = .systemFont(ofSize: 16, weight: .regular)
            static let button: UIFont   = .systemFont(ofSize: 17, weight: .semibold)
        }
        
        enum SymbolConfig {
            static let iconWeight: UIImage.SymbolWeight = .semibold
        }
    }
    
    // MARK: - Colors
    
    private enum Colors {
        static let title: UIColor      = .white
        static let subtitle: UIColor   = UIColor.white.withAlphaComponent(0.8)
        static let buttonBackground: UIColor = UIColor.white.withAlphaComponent(0.9)
        static let buttonForeground: UIColor = .brightPurple
        static let background: UIColor = .brightPurple
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let title = "Заказ успешно оформлен"
        static let subtitle = "Спасибо, что выбрали нас! Продолжайте шопинг."
        static let button = "Вернуться в магазин"
    }
    
    // MARK: - Symbols
    
    private enum Symbols {
        static let success = "checkmark.circle.fill"
    }
    
    // MARK: - UI
    
    private lazy var iconView: UIImageView = {
        let cfg = UIImage.SymbolConfiguration(
            pointSize: Metrics.Sizes.iconPointSize,
            weight: Metrics.SymbolConfig.iconWeight
        )
        let v = UIImageView(image: UIImage(
            systemName: Symbols.success,
            withConfiguration: cfg
        ))
        v.tintColor = .white
        v.contentMode = .scaleAspectFit
        v.setContentHuggingPriority(.required, for: .vertical)
        return v
    }()
    
    private lazy var titleLabel: UILabel = {
        Factory.makeLabel(
            text: Texts.title,
            font: Metrics.Fonts.title,
            color: Colors.title,
            numberOfLines: 0,
            alignment: .center
        )
    }()
    
    private lazy var subtitleLabel: UILabel = {
        Factory.makeLabel(
            text: Texts.subtitle,
            font: Metrics.Fonts.subtitle,
            color: Colors.subtitle,
            numberOfLines: 0,
            alignment: .center
        )
    }()
    
    private lazy var viewOrderButton: UIButton = {
        var conf = UIButton.Configuration.filled()
        conf.title = Texts.button
        conf.baseBackgroundColor = Colors.buttonBackground
        conf.baseForegroundColor = Colors.buttonForeground
        conf.cornerStyle = .capsule
        conf.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = Metrics.Fonts.button
            return out
        }
        let b = UIButton(configuration: conf)
        b.setContentHuggingPriority(.required, for: .vertical)
        b.onTap(self, action: #selector(viewOrderTapped))
        return b
    }()
    
    private lazy var textStack: UIStackView = {
        Factory.makeStack(
            axis: .vertical,
            alignment: .fill,
            spacing: Metrics.Spacing.textStack
        )
    }()
    
    private lazy var rootStack: UIStackView = {
        Factory.makeStack(
            axis: .vertical,
            alignment: .center,
            spacing: Metrics.Spacing.stack
        )
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupHierarchy()
        setupLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - Setup

private extension OrderSuccessViewController {
    func setupAppearance() {
        view.backgroundColor = Colors.background
    }
    
    func setupHierarchy() {
        textStack.addArrangedSubviews(
            titleLabel,
            subtitleLabel
        )
        rootStack.addArrangedSubviews(
            iconView,
            textStack,
            viewOrderButton
        )
        view.addSubview(rootStack)
    }
    
    func setupLayout() {
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rootStack.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            rootStack.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            rootStack.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.layoutMarginsGuide.leadingAnchor
            ),
            rootStack.trailingAnchor.constraint(
                lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor
            ),
            
            viewOrderButton.heightAnchor.constraint(
                greaterThanOrEqualToConstant: Metrics.Sizes.buttonMinHeight
            )
        ])
    }
}

// MARK: - Actions

@objc private extension OrderSuccessViewController {
    func viewOrderTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onViewCatalog?()
    }
}

// MARK: - Helpers

private extension OrderSuccessViewController {
    enum Factory {
        static func makeLabel(
            text: String? = nil,
            font: UIFont,
            color: UIColor,
            numberOfLines: Int = 1,
            alignment: NSTextAlignment = .natural
        ) -> UILabel {
            let l = UILabel()
            l.text = text
            l.font = font
            l.textColor = color
            l.numberOfLines = numberOfLines
            l.textAlignment = alignment
            return l
        }
        
        static func makeStack(
            axis: NSLayoutConstraint.Axis = .vertical,
            alignment: UIStackView.Alignment = .fill,
            spacing: CGFloat = 0,
            distribution: UIStackView.Distribution = .fill
        ) -> UIStackView {
            let v = UIStackView()
            v.axis = axis
            v.alignment = alignment
            v.spacing = spacing
            v.distribution = distribution
            return v
        }
    }
}
