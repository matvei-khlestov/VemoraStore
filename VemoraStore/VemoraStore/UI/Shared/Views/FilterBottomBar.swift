//
//  FilterBottomBar.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 10.10.2025.
//

import UIKit

final class FilterBottomBar: UIView {
    
    // MARK: - API
    
    var onApply: (() -> Void)?
    
    func set(count: Int, hasActiveFilters: Bool) {
        if hasActiveFilters {
            titleLabel.text = "Нашлось \(count) \(pluralize(count))"
            applyButton.setTitle("Показать (\(count))", for: .normal)
        } else {
            titleLabel.text = "Фильтры не установлены"
            applyButton.setTitle("Показать все товары", for: .normal)
        }
    }
    
    // MARK: - UI
    
    private enum Metrics {
        enum Insets {
            static let content: CGFloat = 16
            static let buttonTop: CGFloat = 12
            static let buttonContent = NSDirectionalEdgeInsets(
                top: 0, leading: 16, bottom: 0, trailing: 16
            )
        }
        enum Sizes {
            static let corner: CGFloat = 20
            static let buttonHeight: CGFloat = 52
            static let shadowRadius: CGFloat = 12
            static let shadowOpacity: Float = 0.12
        }
        enum Fonts {
            static let title = UIFont.systemFont(ofSize: 17, weight: .semibold)
            static let button = UIFont.systemFont(ofSize: 17, weight: .semibold)
        }
    }
    
    private enum Colors {
        static let bg = UIColor.systemBackground
        static let title = UIColor.label
        static let buttonBG = UIColor.systemOrange
        static let buttonTitle = UIColor.white
    }
    private enum Texts {
        static let show = "Показать"
    }
    
    private let container = UIView()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = Metrics.Fonts.title
        l.textColor = Colors.title
        return l
    }()
    
    private let applyButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = Texts.show
        config.baseBackgroundColor = Colors.buttonBG
        config.baseForegroundColor = Colors.buttonTitle
        config.cornerStyle = .capsule
        config.contentInsets = Metrics.Insets.buttonContent
        
        let b = UIButton(configuration: config)
        b.titleLabel?.font = Metrics.Fonts.button
        return b
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
        setupHierarchy()
        setupLayout()
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}


// MARK: - Setup

private extension FilterBottomBar {
    func setupAppearance() {
        backgroundColor = .clear
        container.backgroundColor = Colors.bg
        container.layer.cornerRadius = Metrics.Sizes.corner
        container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = Metrics.Sizes.shadowRadius
        layer.shadowOpacity = Metrics.Sizes.shadowOpacity
        layer.shadowOffset = .init(width: 0, height: -2)
    }
    
    func setupHierarchy() {
        addSubview(container)
        container.addSubview(titleLabel)
        container.addSubview(applyButton)
    }
    
    func setupLayout() {
        [container, titleLabel, applyButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(
                equalTo: topAnchor
            ),
            container.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            container.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
            container.bottomAnchor.constraint(
                equalTo: bottomAnchor
            ),
            
            titleLabel.topAnchor.constraint(
                equalTo: container.topAnchor,
                constant: Metrics.Insets.content
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: Metrics.Insets.content)
            ,
            titleLabel.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -Metrics.Insets.content
            ),
            
            applyButton.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: Metrics.Insets.buttonTop
            ),
            applyButton.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: Metrics.Insets.content
            ),
            applyButton.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -Metrics.Insets.content
            ),
            applyButton.heightAnchor.constraint(
                equalToConstant: Metrics.Sizes.buttonHeight
            ),
            applyButton.bottomAnchor.constraint(
                equalTo: container.safeAreaLayoutGuide.bottomAnchor,
                constant: -Metrics.Insets.content
            )
        ])
    }
    
    @objc func applyTapped() {
        onApply?()
    }
    
    func pluralize(_ n: Int) -> String {
        let n10 = n % 10, n100 = n % 100
        if n10 == 1 && n100 != 11 { return "товар" }
        if (2...4).contains(n10) && !(12...14).contains(n100) { return "товара" }
        return "товаров"
    }
}
