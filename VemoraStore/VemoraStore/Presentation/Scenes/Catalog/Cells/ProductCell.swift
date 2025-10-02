//
//  ProductCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//


import UIKit

protocol ProductCellDelegate: AnyObject {
    func productCellDidTapFavorite(_ cell: ProductCell)
    func productCellDidTapAddToCart(_ cell: ProductCell)
}

final class ProductCell: UICollectionViewCell {
    
    // MARK: - Reuse Id
    
    static let reuseId = String(describing: ProductCell.self)
    
    // MARK: - Delegate
    
    weak var delegate: ProductCellDelegate?
    
    // MARK: - State
    
    private var isFavorite = false
    private var isInCart = false
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Corners {
            static let card: CGFloat = 14
            static let image: CGFloat = 12
            static let favoriteBG: CGFloat = 16.5
        }
        enum Shadow {
            static let color: CGColor = UIColor.black.withAlphaComponent(0.06).cgColor
            static let radius: CGFloat = 8
            static let opacity: Float = 1
            static let offset: CGSize = .init(width: 0, height: 4)
        }
        enum Insets {
            static let cardHorizontal: CGFloat = 6
            static let cardVertical: CGFloat = 6
            
            static let imageHorizontal: CGFloat = 12
            static let imageTop: CGFloat = 12
            
            static let favoriteTop: CGFloat = 8
            static let favoriteTrailing: CGFloat = 8
            
            static let labelsHorizontal: CGFloat = 16
            static let addToCartLeading: CGFloat = 12
            static let addToCartBottom: CGFloat = 16
        }
        enum Spacing {
            static let categoryToTitle: CGFloat = 6
            static let titleToPrice: CGFloat = 6
            static let imageToCategory: CGFloat = 10
        }
        enum Sizes {
            static let favoriteBG: CGFloat = 33
        }
        enum Fonts {
            static let category: UIFont = .systemFont(ofSize: 12, weight: .regular)
            static let price: UIFont = .systemFont(ofSize: 20, weight: .bold)
            static let title: UIFont = .systemFont(ofSize: 14, weight: .semibold)
        }
        enum Colors {
            static let imagePlaceholderBackground: UIColor = .black
        }
        enum FavoriteButton {
            static let pointSize: CGFloat = 17
        }
        enum Animations {
            static let highlightScaleDown: CGFloat = 0.98
            static let highlightDuration: TimeInterval = 0.12
        }
    }
    
    // MARK: - UI
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = Metrics.Corners.card
        view.layer.masksToBounds = false
        view.layer.shadowColor = Metrics.Shadow.color
        view.layer.shadowRadius = Metrics.Shadow.radius
        view.layer.shadowOpacity = Metrics.Shadow.opacity
        view.layer.shadowOffset = Metrics.Shadow.offset
        return view
    }()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = Metrics.Corners.image
        view.backgroundColor = Metrics.Colors.imagePlaceholderBackground
        view.image = UIImage(resource: .divan) // заглушка
        return view
    }()
    
    private let favoriteButton: FavoriteButton = {
        let button = FavoriteButton(
            pointSize: Metrics.FavoriteButton.pointSize
        )
        return button
    }()
    
    private let favoriteBG: BlurredIconBackground = {
        let view = BlurredIconBackground(
            cornerRadius: Metrics.Corners.favoriteBG
        )
        return view
    }()
    
    private let categoryLabel: UILabel = {
        let label = ProductCell.makeLabel(
            font: Metrics.Fonts.category,
            textColor: .secondaryLabel
        )
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label =  ProductCell.makeLabel(
            font: Metrics.Fonts.price,
            textColor: .brightPurple
        )
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = ProductCell.makeLabel(
            font: Metrics.Fonts.title,
            textColor: .label,
            numberOfLines: 2
        )
        return label
    }()
    
    private let addToCartButton = AddToCartButton()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        imageView.image = UIImage(resource: .divan)
        titleLabel.text = nil
        categoryLabel.text = nil
        priceLabel.text = nil
        setFavorite(false, animated: false)
        setInCart(false, animated: false)
    }
    
    // MARK: - Highlight animation for whole card
    
    override var isHighlighted: Bool {
        didSet {
            let scale: CGFloat = isHighlighted ? Metrics.Animations.highlightScaleDown : 1.0
            UIView.animate(withDuration: Metrics.Animations.highlightDuration) {
                self.cardView.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }
}

// MARK: - Setup

private extension ProductCell {
    func setupAppearance() {
        contentView.backgroundColor = .clear
    }
    
    func setupHierarchy() {
        contentView.addSubview(cardView)
        
        cardView.addSubviews(
            imageView,
            favoriteBG,
            categoryLabel,
            titleLabel,
            priceLabel,
            addToCartButton
        )
        
        // favorite button into blurred background
        favoriteBG.embed(favoriteButton)
    }
    
    func setupLayout() {
        prepareForAutoLayout()
        setupCardConstraints()
        setupImageSectionConstraints()
        setupInfoSectionConstraints()
    }
    
    func setupActions() {
        favoriteButton.onTap(self, action: #selector(favoriteTapped))
        addToCartButton.onTap(self, action: #selector(addToCartTapped))
    }
}

// MARK: - Layout

private extension ProductCell {
    func prepareForAutoLayout() {
        [cardView,
         imageView,
         favoriteBG,
         categoryLabel,
         priceLabel,
         titleLabel,
         addToCartButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupCardConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Metrics.Insets.cardVertical
            ),
            cardView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Metrics.Insets.cardHorizontal
            ),
            cardView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Metrics.Insets.cardHorizontal
            ),
            cardView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Metrics.Insets.cardVertical
            )
        ])
    }
    
    func setupImageSectionConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(
                equalTo: cardView.topAnchor,
                constant: Metrics.Insets.imageTop
            ),
            imageView.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: Metrics.Insets.imageHorizontal
            ),
            imageView.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -Metrics.Insets.imageHorizontal
            ),
            imageView.heightAnchor.constraint(
                equalTo: imageView.widthAnchor
            ),
            
            favoriteBG.topAnchor.constraint(
                equalTo: imageView.topAnchor,
                constant: Metrics.Insets.favoriteTop
            ),
            favoriteBG.trailingAnchor.constraint(
                equalTo: imageView.trailingAnchor,
                constant: -Metrics.Insets.favoriteTrailing
            ),
            favoriteBG.widthAnchor.constraint(
                equalToConstant: Metrics.Sizes.favoriteBG
            ),
            favoriteBG.heightAnchor.constraint(
                equalToConstant: Metrics.Sizes.favoriteBG
            )
        ])
    }
    
    func setupInfoSectionConstraints() {
        NSLayoutConstraint.activate([
            categoryLabel.topAnchor.constraint(
                equalTo: imageView.bottomAnchor,
                constant: Metrics.Spacing.imageToCategory
            ),
            categoryLabel.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: Metrics.Insets.labelsHorizontal
            ),
            categoryLabel.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -Metrics.Insets.labelsHorizontal
            ),
            
            titleLabel.topAnchor.constraint(
                equalTo: categoryLabel.bottomAnchor,
                constant: Metrics.Spacing.categoryToTitle
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: categoryLabel.leadingAnchor
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -Metrics.Insets.labelsHorizontal
            ),
            
            priceLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: Metrics.Spacing.titleToPrice
            ),
            priceLabel.leadingAnchor.constraint(
                equalTo: categoryLabel.leadingAnchor
            ),
            
            addToCartButton.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: Metrics.Insets.addToCartLeading
            ),
            addToCartButton.bottomAnchor.constraint(
                equalTo: cardView.bottomAnchor,
                constant: -Metrics.Insets.addToCartBottom
            )
        ])
    }
}

// MARK: - Configure API

extension ProductCell {
    func configure(
        with product: ProductTest,
        isFavorite: Bool = false,
        isInCart: Bool = false
    ) {
        titleLabel.text = product.name
        categoryLabel.text = product.categoryId
        priceLabel.text = String(format: "$%.2f", product.price)
        // imageView.kf.setImage(with: product.image)
        
        setFavorite(isFavorite, animated: false)
        setInCart(isInCart, animated: false)
    }
    
    func setFavorite(_ value: Bool, animated: Bool = true) {
        isFavorite = value
        favoriteButton.setFavorite(value, animated: animated)
    }
    
    func setInCart(_ value: Bool, animated: Bool = true) {
        isInCart = value
        addToCartButton.setInCart(value, animated: animated)
    }
}

// MARK: - Actions

private extension ProductCell {
    @objc func favoriteTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        setFavorite(!isFavorite, animated: true)
        favoriteButton.pulse()
        delegate?.productCellDidTapFavorite(self)
    }
    
    @objc func addToCartTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        setInCart(!isInCart, animated: true)
        addToCartButton.pulse()
        delegate?.productCellDidTapAddToCart(self)
    }
}

// MARK: - Helpers

private extension ProductCell {
    static func makeLabel(
        font: UIFont,
        textColor: UIColor,
        numberOfLines: Int = 1,
        alignment: NSTextAlignment = .natural
    ) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = textColor
        label.numberOfLines = numberOfLines
        label.textAlignment = alignment
        return label
    }
}
