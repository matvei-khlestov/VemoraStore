//
//  FavoritesCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 05.09.2025.
//

import UIKit

protocol FavoritesCellDelegate: AnyObject {
    func favoritesCellDidTapCart(_ cell: FavoritesCell)
}

final class FavoritesCell: UITableViewCell {
    
    // MARK: - Reuse Id
    
    static let reuseId = String(describing: FavoritesCell.self)
    
    // MARK: - Delegate
    
    weak var delegate: FavoritesCellDelegate?
    
    // MARK: - State
    
    private var isInCart = false
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let content: UIEdgeInsets = .init(
                top: 12, left: 16, bottom: 12, right: 16
            )
        }
        
        enum Spacing {
            static let rightColumn: CGFloat = 8
            static let actionsRow: CGFloat = 8
            static let thumbToRightColumn: CGFloat = 12
        }
        
        enum Sizes {
            static let thumbWidth: CGFloat = 108
            static let thumbHeight: CGFloat = 106
            static let thumbCornerRadius: CGFloat = 12
        }
        
        enum Fonts {
            static let title: UIFont = .systemFont(ofSize: 16, weight: .semibold)
            static let brand: UIFont = .systemFont(ofSize: 13, weight: .regular)
            static let price: UIFont = .systemFont(ofSize: 18, weight: .bold)
        }
    }
    
    // MARK: - UI
    
    private let thumbImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = Metrics.Sizes.thumbCornerRadius
        view.backgroundColor = .secondarySystemBackground
        return view
    }()
    
    private let titleLabel: UILabel = {
        FavoritesCell.makeLabel(
            font: Metrics.Fonts.title,
            textColor: .label,
            numberOfLines: 2,
            compressionResistance: .defaultLow
        )
    }()
    
    private let brandLabel: UILabel = {
        FavoritesCell.makeLabel(
            font: Metrics.Fonts.brand,
            textColor: .secondaryLabel,
            numberOfLines: 1,
            compressionResistance: .required
        )
    }()
    
    private let priceLabel: UILabel = {
        FavoritesCell.makeLabel(
            font: Metrics.Fonts.price,
            textColor: .brightPurple,
            numberOfLines: 1,
            compressionResistance: .required
        )
    }()
    
    private let cartButton = AddToCartButton()
    
    private let rightStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Metrics.Spacing.rightColumn
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    private let actionsRow: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = Metrics.Spacing.actionsRow
        return stack
    }()
    
    private let spacer: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupAppearance()
        setupHierarchy()
        setupLayout()
        setupActions()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbImageView.image = nil
        titleLabel.text = nil
        brandLabel.text = nil
        priceLabel.text = nil
        setInCart(false, animated: false)
    }
}

// MARK: - Setup

private extension FavoritesCell {
    func setupAppearance() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .systemBackground
        contentView.layoutMargins = Metrics.Insets.content
    }
    
    func setupHierarchy() {
        contentView.addSubviews(thumbImageView, rightStack)
        
        rightStack.addArrangedSubviews(
            brandLabel,
            titleLabel,
            priceLabel,
            actionsRow
        )
        
        actionsRow.addArrangedSubviews(
            cartButton,
            spacer
        )
    }
    
    func setupLayout() {
        prepareForAutoLayout()
        setupThumbConstraints()
        setupRightStackConstraints()
    }
    
    func setupActions() {
        cartButton.onTap(self, action: #selector(cartTapped))
    }
}

// MARK: - Layout

private extension FavoritesCell {
    func prepareForAutoLayout() {
        [thumbImageView, rightStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupThumbConstraints() {
        NSLayoutConstraint.activate([
            thumbImageView.leadingAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.leadingAnchor
            ),
            thumbImageView.topAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.topAnchor
            ),
            thumbImageView.widthAnchor.constraint(
                equalToConstant: Metrics.Sizes.thumbWidth
            ),
            thumbImageView.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor
            )
        ])
        
        let thumbHeight = thumbImageView.heightAnchor.constraint(
            equalToConstant: Metrics.Sizes.thumbHeight
        )
        thumbHeight.priority = .defaultHigh
        thumbHeight.isActive = true
    }
    
    func setupRightStackConstraints() {
        NSLayoutConstraint.activate([
            rightStack.leadingAnchor.constraint(
                equalTo: thumbImageView.trailingAnchor,
                constant: Metrics.Spacing.thumbToRightColumn
            ),
            rightStack.topAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.topAnchor
            ),
            rightStack.trailingAnchor.constraint(
                equalTo: contentView.layoutMarginsGuide.trailingAnchor
            ),
            rightStack.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor
            )
        ])
    }
}

// MARK: - Configure API

extension FavoritesCell {
    func configure(
        with item: FavoriteItem,
        isInCart: Bool = false,
        priceText: String
    ) {
            titleLabel.text = item.title
            brandLabel.text = item.brandName
            priceLabel.text = priceText

            thumbImageView.loadImage(from: item.imageURL)
            
            setInCart(isInCart, animated: false)
        }
    
    func setInCart(_ value: Bool, animated: Bool = true) {
        isInCart = value
        cartButton.setInCart(value, animated: animated)
    }
}

// MARK: - Actions

private extension FavoritesCell {
    @objc func cartTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        setInCart(!isInCart, animated: true)
        cartButton.pulse()
        delegate?.favoritesCellDidTapCart(self)
    }
}

// MARK: - Label Helper

private extension FavoritesCell {
    static func makeLabel(
        font: UIFont,
        textColor: UIColor,
        numberOfLines: Int = 1,
        compressionResistance: UILayoutPriority
    ) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = textColor
        label.numberOfLines = numberOfLines
        label.setContentCompressionResistancePriority(
            compressionResistance, for: .vertical
        )
        return label
    }
}
