//
//  PaymentMethodCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 10.09.2025.
//

import UIKit

/// Ячейка таблицы, используемая в экране оформления заказа (`CheckoutViewController`)
/// для отображения выбранного метода оплаты.
///
/// Содержит:
/// - заголовок блока ("Как оплатить заказ?");
/// - визуальный элемент в виде "пилюли" с текущим методом оплаты (по умолчанию — "При получении");
///
/// Используется для информирования пользователя о способе оплаты
/// и может быть интерактивной при добавлении функционала выбора способа оплаты.

final class PaymentMethodCell: UITableViewCell {
    
    // MARK: - Reuse Id
    
    static let reuseId = String(describing: PaymentMethodCell.self)
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let content: NSDirectionalEdgeInsets = .init(
                top: 15, leading: 16, bottom: 15, trailing: 16
            )
            static let pill: NSDirectionalEdgeInsets = .init(
                top: 10, leading: 12, bottom: 10, trailing: 12
            )
            static let horizontal: CGFloat = 0
            static let verticalTop: CGFloat = 0
            static let verticalBottom: CGFloat = 0
        }
        
        enum Spacing {
            static let verticalStack: CGFloat = 10
        }
        
        enum Fonts {
            static let title: UIFont  = .systemFont(ofSize: 15, weight: .semibold)
            static let method: UIFont = .systemFont(ofSize: 15, weight: .regular)
        }
        
        enum Corners {
            static let pill: CGFloat = 10
        }
        
        enum Borders {
            static let pillWidth: CGFloat = 1.2
        }
    }
    
    // MARK: - Colors
    
    private enum Colors {
        static let title: UIColor  = .label
        static let method: UIColor = .label
        static let pillBackground: UIColor = .secondarySystemBackground
        static let pillBorder: UIColor = .brightPurple
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let title  = "Как оплатить заказ?"
        static let method = "При получении"
    }
    
    // MARK: - UI
    
    private let titleLabel = UILabel.make(
        text: Texts.title,
        font: Metrics.Fonts.title,
        color: Colors.title
    )
    
    private let pillLabel = UILabel.make(
        text: Texts.method,
        font: Metrics.Fonts.method,
        color: Colors.method,
        numberOfLines: 1
    )
    
    private let pillView: UIView = {
        let v = UIView()
        v.backgroundColor = Colors.pillBackground
        v.layer.cornerRadius = Metrics.Corners.pill
        v.layer.borderWidth = Metrics.Borders.pillWidth
        v.layer.borderColor = Colors.pillBorder.cgColor
        return v
    }()
    
    private let rootStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.alignment = .leading
        v.spacing = Metrics.Spacing.verticalStack
        v.isLayoutMarginsRelativeArrangement = true
        v.directionalLayoutMargins = Metrics.Insets.content
        return v
    }()
    
    private let pillContent: UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        v.alignment = .center
        v.isLayoutMarginsRelativeArrangement = true
        v.directionalLayoutMargins = Metrics.Insets.pill
        return v
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupAppearance()
        setupHierarchy()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension PaymentMethodCell {
    func setupAppearance() {
        selectionStyle = .none
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground
    }
    
    func setupHierarchy() {
        pillContent.addArrangedSubview(pillLabel)
        pillView.addSubview(pillContent)
        rootStack.addArrangedSubviews(titleLabel, pillView)
        contentView.addSubview(rootStack)
    }
    
    func setupLayout() {
        [rootStack, pillContent].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            rootStack.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            rootStack.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            rootStack.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            ),
            
            pillContent.topAnchor.constraint(
                equalTo: pillView.topAnchor
            ),
            pillContent.leadingAnchor.constraint(
                equalTo: pillView.leadingAnchor
            ),
            pillContent.trailingAnchor.constraint(
                equalTo: pillView.trailingAnchor
            ),
            pillContent.bottomAnchor.constraint(
                equalTo: pillView.bottomAnchor
            )
        ])
    }
}

// MARK: - Configure API

extension PaymentMethodCell {
    func configure(
        title: String = Texts.title,
        method: String = Texts.method
    ) {
        titleLabel.text = title
        pillLabel.text = method
    }
}

// MARK: - Helper

private extension UILabel {
    static func make(
        text: String? = nil,
        font: UIFont,
        color: UIColor,
        numberOfLines: Int = 0,
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
}
