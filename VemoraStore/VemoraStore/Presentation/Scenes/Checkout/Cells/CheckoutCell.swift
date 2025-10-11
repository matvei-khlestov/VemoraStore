//
//  CheckoutCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 10.09.2025.
//


import UIKit

final class CheckoutCell: UITableViewCell {
    
    // MARK: - Reuse Id
    
    static let reuseId = String(describing: CheckoutCell.self)
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            // Универсальные базовые отступы (на уровне экрана)
            static let horizontal: CGFloat = 0
            static let verticalTop: CGFloat = 0
            static let verticalBottom: CGFloat = 0
            
            // Контентные отступы ячейки
            static let content: NSDirectionalEdgeInsets = .init(
                top: 12, leading: 16, bottom: 12, trailing: 16
            )
        }
        
        enum Spacing {
            static let inlineElements: CGFloat = 8
            static let verticalStack: CGFloat = 6
        }
        
        enum Fonts {
            static let title: UIFont = .systemFont(ofSize: 16, weight: .semibold)
            static let category: UIFont = .systemFont(ofSize: 12, weight: .regular)
            static let price: UIFont = .systemFont(ofSize: 18, weight: .bold)
            static let quantity: UIFont = .systemFont(ofSize: 15, weight: .medium)
        }
        
        enum Sizes {
            static let thumb: CGFloat = 110
        }
        
        enum Corners {
            static let thumb: CGFloat = 12
        }
        
        enum Table {
            static let separatorHeight: CGFloat = 0.5
            static let separatorHorizontalInset: CGFloat = 16
        }
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
        CheckoutCell.makeLabel(
            font: Metrics.Fonts.title,
            textColor: .label,
            numberOfLines: 2,
            compression: .defaultLow
        )
    }()
    
    private let categoryLabel: UILabel = {
        CheckoutCell.makeLabel(
            font: Metrics.Fonts.category,
            textColor: .secondaryLabel,
            compression: .required
        )
    }()
    
    private let priceLabel: UILabel = {
        CheckoutCell.makeLabel(
            font: Metrics.Fonts.price,
            textColor: .brightPurple,
            compression: .required
        )
    }()
    
    private let quantityLabel: UILabel = {
        let l = UILabel()
        l.font = Metrics.Fonts.quantity
        l.textColor = .secondaryLabel
        return l
    }()
    
    /// Вертикальный стек справа от изображения
    private let rightStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.alignment = .fill
        v.spacing = Metrics.Spacing.verticalStack
        return v
    }()
    
    /// Нижний разделитель
    private let separatorView: UIView = {
        let v = UIView()
        v.backgroundColor = .separator
        return v
    }()
    
    /// Контроль видимости разделителя
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
        titleLabel.text = nil
        categoryLabel.text = nil
        priceLabel.text = nil
        quantityLabel.text = nil
        showsSeparator = true
    }
}

// MARK: - Setup

private extension CheckoutCell {
    func setupAppearance() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .systemBackground
    }
    
    func setupHierarchy() {
        // Стек справа
        rightStack.addArrangedSubviews(
            categoryLabel,
            titleLabel,
            priceLabel,
            quantityLabel
        )
        
        contentView.addSubviews(
            thumbImageView,
            rightStack,
            separatorView
        )
    }
    
    func setupLayout() {
        prepareForAutoLayout()
        setupThumbConstraints()
        setupRightStackConstraints()
        setupSeparatorConstraints()
        separatorView.isHidden = !showsSeparator
    }
    
    func prepareForAutoLayout() {
        [thumbImageView, rightStack, separatorView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupThumbConstraints() {
        NSLayoutConstraint.activate([
            thumbImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Metrics.Insets.content.leading
            ),
            thumbImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Metrics.Insets.content.top
            ),
            thumbImageView.widthAnchor.constraint(
                equalToConstant: Metrics.Sizes.thumb
            ),
            thumbImageView.heightAnchor.constraint(
                equalToConstant: Metrics.Sizes.thumb
            ),
            thumbImageView.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor,
                constant: -Metrics.Insets.content.bottom
            )
        ])
    }
    
    func setupRightStackConstraints() {
        NSLayoutConstraint.activate([
            rightStack.leadingAnchor.constraint(
                equalTo: thumbImageView.trailingAnchor,
                constant: Metrics.Spacing.inlineElements
            ),
            rightStack.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Metrics.Insets.content.top
            ),
            rightStack.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Metrics.Insets.content.trailing
            ),
            rightStack.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor,
                constant: -Metrics.Insets.content.bottom
            )
        ])
    }
    
    
    func setupSeparatorConstraints() {
        NSLayoutConstraint.activate([
            separatorView.heightAnchor.constraint(
                equalToConstant: Metrics.Table.separatorHeight
            ),
            separatorView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Metrics.Table.separatorHorizontalInset
            ),
            separatorView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Metrics.Table.separatorHorizontalInset
            ),
            separatorView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            )
        ])
    }
}

// MARK: - Configure API

extension CheckoutCell {
    func configure(with product: Product, quantity: Int) {
        titleLabel.text = product.name
        categoryLabel.text = product.categoryId
        priceLabel.text = String(format: "$%.2f", product.price)
        quantityLabel.text = "x\(quantity)"
        // thumbImageView.kf.setImage(with: product.image)
        thumbImageView.image = UIImage(resource: .divan) // заглушка
    }
}

// MARK: - Helpers

private extension CheckoutCell {
    static func makeLabel(
        font: UIFont,
        textColor: UIColor,
        numberOfLines: Int = 1,
        compression: UILayoutPriority? = nil
    ) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = textColor
        label.numberOfLines = numberOfLines
        if let compression {
            label.setContentCompressionResistancePriority(
                compression, for: .vertical
            )
        }
        return label
    }
}
