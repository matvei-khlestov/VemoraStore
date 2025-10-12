//
//  CartCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.09.2025.
//


import UIKit
import Kingfisher

protocol CartCellDelegate: AnyObject {
    /// Вызывается при изменении количества (после каждого тапа −/+)
    func cartCell(_ cell: CartCell, didChangeQuantity quantity: Int)
}

final class CartCell: UITableViewCell {
    
    // MARK: - Reuse Id
    
    static let reuseId = String(describing: CartCell.self)
    
    // MARK: - Delegate
    
    weak var delegate: CartCellDelegate?
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 16
            static let verticalTop: CGFloat = 12
            static let verticalBottom: CGFloat = 12
            static let betweenThumbAndRight: CGFloat = 12
            static let actionButtonsContent: NSDirectionalEdgeInsets = .init(
                top: 6, leading: 10, bottom: 6, trailing: 10
            )
        }
        enum Spacing {
            static let rightStack: CGFloat = 8
            static let actionsRow: CGFloat = 8
        }
        enum Sizes {
            static let thumbWidth: CGFloat = 108
            static let thumbHeight: CGFloat = 105
            static let qtyHeight: CGFloat = 32
            static let qtyWidth: CGFloat = 100
            static let deleteButton: CGFloat = 30
        }
        enum Corners {
            static let thumb: CGFloat = 12
            static let qtyContainer: CGFloat = 16
            static let deleteButton: CGFloat = 16
        }
        enum Fonts {
            static let title: UIFont = .systemFont(ofSize: 16, weight: .semibold)
            static let brand: UIFont = .systemFont(ofSize: 13, weight: .regular)
            static let price: UIFont = .systemFont(ofSize: 18, weight: .bold)
            static let quantity: UIFont = .systemFont(ofSize: 15, weight: .semibold)
        }
    }
    
    // MARK: - Symbols
    
    private enum Symbols {
        static let minus = "minus"
        static let plus = "plus"
        static let trash = "trash"
    }
    
    // MARK: - State
    
    private var quantity: Int = 1 {
        didSet {
            quantityLabel.text = "\(quantity)"
            minusButton.isEnabled = quantity > 1
        }
    }
    
    // MARK: - UI
    
    private let thumbImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = Metrics.Corners.thumb
        view.backgroundColor = .secondarySystemBackground
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = CartCell.makeLabel(
            font: Metrics.Fonts.title,
            textColor: .label,
            numberOfLines: 2,
            compressionResistance: .defaultLow
        )
        return label
    }()
    
    private let brandLabel: UILabel = {
        let label =  CartCell.makeLabel(
            font: Metrics.Fonts.brand,
            textColor: .secondaryLabel,
            numberOfLines: 1,
            compressionResistance: .required
        )
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = CartCell.makeLabel(
            font: Metrics.Fonts.price,
            textColor: .brightPurple,
            numberOfLines: 1,
            compressionResistance: .required
        )
        return label
    }()
    
    private let minusButton: UIButton = {
        let button = CartCell.makeActionButton(systemName: Symbols.minus)
        return button
    }()
    
    private let plusButton: UIButton = {
        let button =  CartCell.makeActionButton(systemName: Symbols.plus)
        return button
    }()
    
    /// Капсула количества (− 1 +)
    private let qtyContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = Metrics.Corners.qtyContainer
        view.layer.masksToBounds = true
        return view
    }()
    
    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.textAlignment = .center
        label.font = Metrics.Fonts.quantity
        label.textColor = .label
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()
    
    /// Вертикальный стек справа от картинки
    private let rightStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Metrics.Spacing.rightStack
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    /// Горизонтальная строка действий: счётчик слева + удалить справа
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
        setQuantity(1, notify: false)
    }
}

// MARK: - Setup

private extension CartCell {
    func setupAppearance() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .systemBackground
        contentView.layoutMargins = .init(
            top: Metrics.Insets.verticalTop,
            left: Metrics.Insets.horizontal,
            bottom: Metrics.Insets.verticalBottom,
            right: Metrics.Insets.horizontal
        )
    }
    
    func setupHierarchy() {
        // Внешняя иерархия
        contentView.addSubviews(thumbImageView, rightStack)
        
        // Внутренняя иерархия
        rightStack.addArrangedSubviews(
            brandLabel,
            titleLabel,
            priceLabel,
            actionsRow
        )
        
        qtyContainer.addSubviews(
            minusButton,
            quantityLabel,
            plusButton
        )
        
        actionsRow.addArrangedSubviews(
            qtyContainer,
            spacer
        )
    }
    
    func setupLayout() {
        prepareForAutoLayout()
        setupThumbConstraints()
        setupRightStackConstraints()
        setupQtyConstraints()
        
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        priceLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        brandLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    func setupActions() {
        minusButton.onTap(self, action: #selector(decreaseTapped))
        plusButton.onTap(self, action: #selector(increaseTapped))
    }
}

// MARK: - Layout

private extension CartCell {
    func prepareForAutoLayout() {
        [thumbImageView,
         rightStack,
         qtyContainer,
         minusButton,
         quantityLabel,
         plusButton].forEach {
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
                constant: Metrics.Insets.betweenThumbAndRight
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
    
    func setupQtyConstraints() {
        NSLayoutConstraint.activate([
            qtyContainer.heightAnchor.constraint(
                equalToConstant: Metrics.Sizes.qtyHeight
            ),
            qtyContainer.widthAnchor.constraint(
                equalToConstant: Metrics.Sizes.qtyWidth
            ),
            
            minusButton.leadingAnchor.constraint(
                equalTo: qtyContainer.leadingAnchor
            ),
            minusButton.topAnchor.constraint(
                equalTo: qtyContainer.topAnchor
            ),
            minusButton.bottomAnchor.constraint(
                equalTo: qtyContainer.bottomAnchor
            ),
            
            plusButton.trailingAnchor.constraint(
                equalTo: qtyContainer.trailingAnchor
            ),
            plusButton.topAnchor.constraint(
                equalTo: qtyContainer.topAnchor
            ),
            plusButton.bottomAnchor.constraint(
                equalTo: qtyContainer.bottomAnchor
            ),
            
            quantityLabel.centerXAnchor.constraint(
                equalTo: qtyContainer.centerXAnchor
            ),
            quantityLabel.centerYAnchor.constraint(
                equalTo: qtyContainer.centerYAnchor
            )
        ])
    }
}

// MARK: - Configure API

extension CartCell {
    func configure(with item: CartItem) {
        titleLabel.text = item.title
        brandLabel.text = item.brandName
        priceLabel.text = "\(item.lineTotal) ₽"
        
        let url = URL(string: item.imageURL ?? "")
        thumbImageView.kf.setImage(with: url)
        setQuantity(item.quantity, notify: false)
    }
    
    func setQuantity(_ value: Int, notify: Bool = true) {
        quantity = max(1, value)
        if notify { delegate?.cartCell(self, didChangeQuantity: quantity) }
    }
}

// MARK: - Actions

private extension CartCell {
    @objc func decreaseTapped() {
        guard quantity > 1 else { return }
        quantity -= 1
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        delegate?.cartCell(self, didChangeQuantity: quantity)
    }
    
    @objc func increaseTapped() {
        quantity += 1
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        delegate?.cartCell(self, didChangeQuantity: quantity)
    }
}

// MARK: - Helpers

private extension CartCell {
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
        label.setContentCompressionResistancePriority(compressionResistance, for: .vertical)
        return label
    }
    
    static func makeActionButton(systemName: String) -> UIButton {
        var conf = UIButton.Configuration.plain()
        conf.image = UIImage(systemName: systemName)
        conf.baseForegroundColor = .brightPurple
        conf.contentInsets = Metrics.Insets.actionButtonsContent
        return UIButton(configuration: conf)
    }
}


