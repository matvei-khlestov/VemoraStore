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

    static let reuseId = "ProductCell"
    weak var delegate: ProductCellDelegate?

    // MARK: - State
    private var isFavorite: Bool = false
    private var isInCart: Bool = false

    // MARK: UI
    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 14
        v.layer.masksToBounds = false
        v.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        v.layer.shadowRadius = 8
        v.layer.shadowOpacity = 1
        v.layer.shadowOffset = .init(width: 0, height: 4)
        return v
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = .secondarySystemBackground
        iv.image = UIImage(resource: .divan) // заглушка
        return iv
    }()

    private let favoriteButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "heart"), for: .normal)
        b.tintColor = UIColor(named: "AppAccent") ?? UIColor(red: 0.6078, green: 0.1882, blue: 1.0, alpha: 1.0) // #9B30FF
        b.backgroundColor = .systemBackground
        b.layer.cornerRadius = 16
        return b
    }()

    private let categoryLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = .secondaryLabel
        return l
    }()

    private let priceLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textColor = UIColor(named: "AppAccent") ?? UIColor(red: 0.6078, green: 0.1882, blue: 1.0, alpha: 1.0)
        return l
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = .label
        l.numberOfLines = 2
        return l
    }()

    private let addToCartButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "cart.badge.plus"), for: .normal)
        b.tintColor = UIColor(named: "AppAccent") ?? UIColor(red: 0.6078, green: 0.1882, blue: 1.0, alpha: 1.0)
        b.backgroundColor = .systemBackground
        b.layer.cornerRadius = 14
        return b
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        addToCartButton.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Highlight animation for whole card
    override var isHighlighted: Bool {
        didSet {
            let scale: CGFloat = isHighlighted ? 0.98 : 1.0
            UIView.animate(withDuration: 0.12) {
                self.cardView.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }

    // MARK: - Layout
    private func setupLayout() {
        contentView.backgroundColor = .clear
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false

        [imageView, favoriteButton, categoryLabel, priceLabel, titleLabel, addToCartButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            imageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            favoriteButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 8),
            favoriteButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -8),
            favoriteButton.widthAnchor.constraint(equalToConstant: 30),
            favoriteButton.heightAnchor.constraint(equalToConstant: 30),

            categoryLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            categoryLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            categoryLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            priceLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 6),
            priceLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),

            titleLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            addToCartButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            addToCartButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            addToCartButton.widthAnchor.constraint(equalToConstant: 40),
            addToCartButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    // MARK: - API
    func configure(with product: Product, isFavorite: Bool = false, isInCart: Bool = false) {
        titleLabel.text = product.name
        categoryLabel.text = product.categoryId
        priceLabel.text = String(format: "$%.2f", product.price)

        setFavorite(isFavorite, animated: false)
        setInCart(isInCart, animated: false)
        // imageView.kf.setImage(with: product.image)
    }

    func setFavorite(_ value: Bool, animated: Bool = true) {
        isFavorite = value
        let img = UIImage(systemName: value ? "heart.fill" : "heart")
        let apply = { self.favoriteButton.setImage(img, for: .normal) }
        animated
        ? UIView.transition(with: favoriteButton, duration: 0.18, options: .transitionCrossDissolve, animations: apply)
        : apply()
    }

    func setInCart(_ value: Bool, animated: Bool = true) {
        isInCart = value
        let img = UIImage(systemName: value ? "cart.fill.badge.minus" : "cart.badge.plus")
        let apply = { self.addToCartButton.setImage(img, for: .normal) }
        animated
        ? UIView.transition(with: addToCartButton, duration: 0.18, options: .transitionCrossDissolve, animations: apply)
        : apply()
    }

    // MARK: - Actions
    @objc private func favoriteTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        setFavorite(!isFavorite, animated: true)
        favoriteButton.pulse()
        delegate?.productCellDidTapFavorite(self)
    }

    @objc private func addToCartTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        setInCart(!isInCart, animated: true)
        addToCartButton.pulse()
        delegate?.productCellDidTapAddToCart(self)
    }
}

