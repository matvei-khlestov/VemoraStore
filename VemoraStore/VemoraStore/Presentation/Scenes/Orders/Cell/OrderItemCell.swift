//
//  OrderItemCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 18.09.2025.
//

import UIKit

final class OrderItemCell: UITableViewCell {
    
    // MARK: - Reuse Id
    
    static let reuseId = String(describing: OrderItemCell.self)
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let content = NSDirectionalEdgeInsets(
                top: 12,
                leading: 16,
                bottom: 12,
                trailing: 16
            )
        }
        
        enum Spacing {
            static let horizontal: CGFloat = 8
            static let vertical: CGFloat = 6
            static let meta: CGFloat = 8
            static let metaInner: CGFloat = 4
        }
        
        enum Sizes {
            static let thumbSide: CGFloat = 110
        }
        
        enum Corners {
            static let thumb: CGFloat = 12
        }
        
        enum Fonts {
            static let title: UIFont    = .systemFont(ofSize: 16, weight: .semibold)
            static let brand: UIFont = .systemFont(ofSize: 12, weight: .regular)
            static let price: UIFont    = .systemFont(ofSize: 18, weight: .bold)
            static let qty: UIFont      = .systemFont(ofSize: 15, weight: .medium)
            static let meta: UIFont     = .systemFont(ofSize: 14, weight: .regular)
        }
        
        enum Separator {
            static let height: CGFloat = 0.5
            static let leadingInset: CGFloat = 16
            static let trailingInset: CGFloat = 16
        }
    }
    
    // MARK: - Colors
    
    private enum Colors {
        static let title: UIColor    = .label
        static let category: UIColor = .secondaryLabel
        static let price: UIColor    = .brightPurple
        static let qty: UIColor      = .secondaryLabel
        static let meta: UIColor     = .secondaryLabel
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let addressPrefix = "Адрес: "
        static let datePrefix    = "Дата создания: "
        static let paymentPrefix = "Оплата: "
        static func quantity(_ value: Int) -> String { "x\(value)" }
    }
    
    // MARK: - UI
    
    private let thumbImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.layer.cornerRadius = Metrics.Corners.thumb
        v.backgroundColor = .secondarySystemBackground
        return v
    }()
    
    private let titleLabel: UILabel = {
        Factory.makeLabel(
            font: Metrics.Fonts.title,
            color: Colors.title,
            numberOfLines: 0
        )
    }()
    
    private let brandLabel: UILabel = {
        Factory.makeLabel(
            font: Metrics.Fonts.brand,
            color: Colors.category
        )
    }()
    
    private let priceLabel: UILabel = {
        Factory.makeLabel(
            font: Metrics.Fonts.price,
            color: Colors.price
        )
    }()
    
    private let quantityLabel: UILabel = {
        Factory.makeLabel(
            font: Metrics.Fonts.qty,
            color: Colors.qty
        )
    }()
    
    private let rightStack: UIStackView = {
        Factory.makeStack(
            axis: .vertical,
            alignment: .fill,
            spacing: Metrics.Spacing.vertical
        )
    }()
    
    private let metaStack: UIStackView = {
        Factory.makeStack(
            axis: .vertical,
            alignment: .fill,
            spacing: Metrics.Spacing.metaInner
        )
    }()
    
    private let addressLabel: UILabel = {
        Factory.makeLabel(
            font: Metrics.Fonts.meta,
            color: Colors.meta,
            numberOfLines: 0
        )
    }()
    
    private let dateLabel: UILabel = {
        Factory.makeLabel(
            font: Metrics.Fonts.meta,
            color: Colors.meta,
            numberOfLines: 0
        )
    }()
    
    private let paymentLabel: UILabel = {
        Factory.makeLabel(
            font: Metrics.Fonts.meta,
            color: Colors.meta
        )
    }()
    
    private let statusBadge = BadgeView()
    
    private let infoStack: UIStackView = {
        Factory.makeStack(
            axis: .vertical,
            alignment: .leading,
            spacing: Metrics.Spacing.meta
        )
    }()
    
    private let separatorView: UIView = {
        let v = UIView()
        v.backgroundColor = .separator
        return v
    }()
    
    /// Показ/скрытие тонкой линии внизу
    var showsSeparator: Bool = true {
        didSet { separatorView.isHidden = !showsSeparator }
    }
    
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
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbImageView.image = nil
        [titleLabel, brandLabel, priceLabel, quantityLabel,
         addressLabel, dateLabel, paymentLabel].forEach {
            $0.text = nil
        }
        showsSeparator = true
    }
}

// MARK: - Setup

private extension OrderItemCell {
    func setupAppearance() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .systemBackground
        contentView.directionalLayoutMargins = Metrics.Insets.content
        
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        [brandLabel, priceLabel].forEach {
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
        }
    }
    
    func setupHierarchy() {
        // Правая колонка
        rightStack.addArrangedSubviews(
            brandLabel,
            titleLabel,
            priceLabel,
            quantityLabel
        )
        // Мета-инфо + бейдж
        metaStack.addArrangedSubviews(
            addressLabel,
            dateLabel,
            paymentLabel
        )
        infoStack.addArrangedSubviews(
            metaStack,
            statusBadge
        )
        
        contentView.addSubviews(
            thumbImageView,
            rightStack,
            infoStack,
            separatorView
        )
    }
    
    func setupLayout() {
        prepareForAutoLayout()
        setupThumbConstraints()
        setupRightStackConstraints()
        setupInfoStackConstraints()
        setupSeparatorConstraints()
    }
}

// MARK: - Layout

private extension OrderItemCell {
    func prepareForAutoLayout() {
        [thumbImageView, rightStack, infoStack, separatorView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupThumbConstraints() {
        NSLayoutConstraint.activate([
            thumbImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 15
            ),
            thumbImageView.topAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.topAnchor
            ),
            thumbImageView.widthAnchor.constraint(
                equalToConstant: Metrics.Sizes.thumbSide
            ),
            thumbImageView.heightAnchor.constraint(
                equalToConstant: Metrics.Sizes.thumbSide
            )
        ])
    }
    
    func setupRightStackConstraints() {
        NSLayoutConstraint.activate([
            rightStack.leadingAnchor.constraint(
                equalTo: thumbImageView.trailingAnchor,
                constant: Metrics.Spacing.horizontal
            ),
            rightStack.topAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.topAnchor
            ),
            rightStack.trailingAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.trailingAnchor
            )
        ])
    }
    
    func setupInfoStackConstraints() {
        NSLayoutConstraint.activate([
            infoStack.leadingAnchor.constraint(
                equalTo: rightStack.leadingAnchor
            ),
            infoStack.trailingAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.trailingAnchor
            ),
            infoStack.topAnchor.constraint(
                equalTo: rightStack.bottomAnchor,
                constant: Metrics.Spacing.meta
            ),
            infoStack.bottomAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.bottomAnchor
            )
        ])
    }
    
    func setupSeparatorConstraints() {
        NSLayoutConstraint.activate([
            separatorView.heightAnchor.constraint(
                equalToConstant: Metrics.Separator.height
            ),
            separatorView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Metrics.Separator.leadingInset
            ),
            separatorView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Metrics.Separator.trailingInset
            ),
            separatorView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            )
        ])
        separatorView.isHidden = !showsSeparator
    }
}

// MARK: - Configure API

extension OrderItemCell {
    func configure(
        item: OrderItem,
        order: OrderEntity,
        priceText: String
    ) {
        
        titleLabel.text = item.product.name
        brandLabel.text = item.product.brandId
        priceLabel.text = priceText
        quantityLabel.text = Texts.quantity(item.quantity)
        
        thumbImageView.loadImage(from: item.product.imageURL)
        
        addressLabel.text = Texts.addressPrefix + order.receiveAddress
        dateLabel.text = Texts.datePrefix + order.createdAt.description
        paymentLabel.text = Texts.paymentPrefix + order.paymentMethod
        
        let color: UIColor = {
            switch order.status {
            case .assembling:
                return .systemOrange
            case .ready:
                return .systemBlue
            case .delivering:
                return .systemTeal
            case .delivered:
                return .systemGreen
            case .cancelled:
                return .systemRed
            }
        }()
        statusBadge.configure(text: order.status.badgeText, color: color)
    }
}

// MARK: - Helpers

private extension OrderItemCell {
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
