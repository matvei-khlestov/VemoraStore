//
//  DeliveryInfoCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 10.09.2025.
//

import UIKit

final class DeliveryInfoCell: UITableViewCell {
    
    // MARK: - Reuse Id
    
    static let reuseId = String(describing: DeliveryInfoCell.self)
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 0
            static let verticalTop: CGFloat = 0
            static let verticalBottom: CGFloat = 0
            static let content: NSDirectionalEdgeInsets = .init(
                top: 15, leading: 16, bottom: 15, trailing: 16
            )
        }
        
        enum Spacing {
            static let verticalStack: CGFloat = 8
        }
        
        enum Fonts {
            static let title: UIFont = .systemFont(ofSize: 13, weight: .medium)
            static let when:  UIFont = .systemFont(ofSize: 17, weight: .bold)
            static let cost:  UIFont = .systemFont(ofSize: 15, weight: .medium)
        }
    }
    
    // MARK: - Colors
    
    private enum Colors {
        static let title: UIColor = .secondaryLabel
        static let when:  UIColor = .label
        static let cost:  UIColor = .systemGreen
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let title = "Доставка Vemora Store"
    }
    
    // MARK: - UI
    
    private let titleLabel = UILabel.make(
        text: Texts.title,
        font: Metrics.Fonts.title,
        color: Colors.title
    )
    
    private let whenLabel = UILabel.make(
        font: Metrics.Fonts.when,
        color: Colors.when
    )
    
    private let costLabel = UILabel.make(
        font: Metrics.Fonts.cost,
        color: Colors.cost,
        numberOfLines: 1
    )
    
    private let vStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.alignment = .fill
        v.spacing = Metrics.Spacing.verticalStack
        v.isLayoutMarginsRelativeArrangement = true
        v.directionalLayoutMargins = Metrics.Insets.content
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

private extension DeliveryInfoCell {
    func setupAppearance() {
        selectionStyle = .none
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground
    }
    
    func setupHierarchy() {
        vStack.addArrangedSubviews(
            titleLabel,
            whenLabel,
            costLabel
        )
        contentView.addSubview(vStack)
    }
    
    func setupLayout() {
        prepareForAutoLayout()
        setupStackConstraints()
    }
}

// MARK: - Layout

private extension DeliveryInfoCell {
    func prepareForAutoLayout() {
        [vStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupStackConstraints() {
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            vStack.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            vStack.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            vStack.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            )
        ])
    }
}

// MARK: - Configure API

extension DeliveryInfoCell {
    func configure(when: String, cost: String) {
        whenLabel.text = when
        costLabel.text = cost
    }
}

// MARK: - Helper

private extension UILabel {
    static func make(
        text: String? = nil,
        font: UIFont,
        color: UIColor,
        numberOfLines: Int = 0
    ) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = font
        l.textColor = color
        l.numberOfLines = numberOfLines
        return l
    }
}
