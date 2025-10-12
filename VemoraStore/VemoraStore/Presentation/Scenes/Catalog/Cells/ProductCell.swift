//
//  ProductCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//


import UIKit
import Kingfisher
import Combine

protocol ProductCellDelegate: AnyObject {
    func productCell(_ cell: ProductCell, didToggleCart toInCart: Bool)
    func productCellDidTapFavorite(_ cell: ProductCell)
}

final class ProductCell: UICollectionViewCell {
    
    // MARK: - Reuse Id
    
    static let reuseId = String(describing: ProductCell.self)
    
    // MARK: - Delegate
    
    weak var delegate: ProductCellDelegate?
    
    // MARK: - State
    
    private var isFavorite = false
    private var isInCart = false
    private var bag = Set<AnyCancellable>()
    private var productId: String?
    
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
            
            static let favoriteTop: CGFloat = 6
            static let favoriteTrailing: CGFloat = 6
            
            static let labelsHorizontal: CGFloat = 16
            static let addToCartLeading: CGFloat = 12
            static let addToCartBottom: CGFloat = 16
        }
        
        enum Spacing {
            static let titleToPrice: CGFloat = 6
            static let imageToCategory: CGFloat = 10
        }
        
        enum Sizes {
            static let favoriteBG: CGFloat = 33
        }
        
        enum Fonts {
            static let price: UIFont = .systemFont(ofSize: 18, weight: .bold)
            static let title: UIFont = .systemFont(ofSize: 15, weight: .semibold)
            static let brand: UIFont = .systemFont(ofSize: 13, weight: .regular)
        }
        
        enum Colors {
            static let imagePlaceholderBackground: UIColor = .white
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
        view.backgroundColor = .secondarySystemGroupedBackground
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
        return view
    }()
    
    private let favoriteButton: FavoriteButton = {
        let button = FavoriteButton(
            pointSize: Metrics.FavoriteButton.pointSize
        )
        return button
    }()
    
    private let priceLabel: UILabel = {
        let label =  ProductCell.makeLabel(
            font: Metrics.Fonts.price,
            textColor: .brightPurple
        )
        return label
    }()
    
    private let brandLabel: UILabel = {
        let label = ProductCell.makeLabel(
            font: Metrics.Fonts.brand,
            textColor: .secondaryLabel
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
        bag.removeAll()
        productId = nil
        imageView.image = UIImage(resource: .divan)
        titleLabel.text = nil
        brandLabel.text = nil
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
            favoriteButton,
            brandLabel,
            titleLabel,
            priceLabel,
            addToCartButton
        )
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
         favoriteButton,
         priceLabel,
         brandLabel,
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
            
            favoriteButton.topAnchor.constraint(
                equalTo: imageView.topAnchor,
                constant: Metrics.Insets.favoriteTop
            ),
            favoriteButton.trailingAnchor.constraint(
                equalTo: imageView.trailingAnchor,
                constant: -Metrics.Insets.favoriteTrailing
            )
        ])
    }
    
    func setupInfoSectionConstraints() {
        NSLayoutConstraint.activate([
            brandLabel.topAnchor.constraint(
                equalTo: imageView.bottomAnchor,
                constant: Metrics.Spacing.imageToCategory
            ),
            brandLabel.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: Metrics.Insets.labelsHorizontal
            ),
            brandLabel.trailingAnchor.constraint(
                equalTo: cardView.trailingAnchor,
                constant: -Metrics.Insets.labelsHorizontal
            ),
            
            titleLabel.topAnchor.constraint(
                equalTo: brandLabel.bottomAnchor,
                constant: 4
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: cardView.leadingAnchor,
                constant: Metrics.Insets.labelsHorizontal
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
                equalTo: titleLabel.leadingAnchor
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
        with product: Product,
        isFavorite: Bool = false,
        isInCart: Bool = false
    ) {
        self.productId = product.id
        titleLabel.text = product.name
        brandLabel.text = product.brandId
        priceLabel.text = "\(product.price) ₽"
        let url = URL(string: product.imageURL)
        imageView.kf.setImage(with: url)
        
        setFavorite(isFavorite, animated: false)
        setInCart(isInCart, animated: false)
    }

    /// Подписка ячейки на состояние корзины: кнопка обновится автоматически при изменении.
    func bindCartState(cartIdsPublisher: AnyPublisher<Set<String>, Never>) {
        guard let productId = productId else { return }

        // Сбросить прошлые подписки (важно для reuse)
        bag.removeAll()

        cartIdsPublisher
            .map { $0.contains(productId) }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] inCart in
                self?.setInCart(inCart, animated: true)
            }
            .store(in: &bag)
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
        let next = !isInCart          // хотим стать в корзине/выйти из неё
        setInCart(next, animated: true)
        addToCartButton.pulse()
        delegate?.productCell(self, didToggleCart: next)
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
