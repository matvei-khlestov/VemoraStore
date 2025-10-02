//
//  ProductDetailsViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit

final class ProductDetailsViewController: UIViewController {
    
    // MARK: - Public Callbacks
    
    var onBack: (() -> Void)?
    
    // MARK: - Dependencies
    
    private let viewModel: ProductDetailsViewModelProtocol
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 16
            static let verticalTop: CGFloat = 16
            static let verticalBottom: CGFloat = 16
        }
        enum Spacing {
            static let verticalStack: CGFloat = 16
            static let likePadding: CGFloat = 12
        }
        enum Fonts {
            static let title: UIFont = .systemFont(ofSize: 20, weight: .bold)
            static let description: UIFont = .systemFont(ofSize: 15, weight: .regular)
            static let price: UIFont = .systemFont(ofSize: 18, weight: .semibold)
        }
        enum Sizes {
            static let likeButton: CGFloat = 36
            static let favoriteSymbolPointSize: CGFloat = 18
            static let cartSymbolPointSize: CGFloat = 30
        }
        enum Corners {
            static let image: CGFloat = 12
        }
        enum Layout {
            static let imageAspect: CGFloat = 3.0 / 4.0
        }
    }
    
    // MARK: - State
    
    private var isFavorite = false
    private var isInCart = false
    
    // MARK: - UI
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = true
        return view
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Metrics.Spacing.verticalStack
        stack.addArrangedSubviews(
            imageContainer,
            titleLabel,
            descriptionLabel,
            priceLabel,
            controlsRow
        )
        return stack
    }()
    
    private lazy var addToCartButton: AddToCartButton = {
        AddToCartButton(symbolPointSize: Metrics.Sizes.cartSymbolPointSize)
    }()
    
    private lazy var favoriteButton: FavoriteButton = {
        FavoriteButton(pointSize: Metrics.Sizes.favoriteSymbolPointSize)
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = Metrics.Corners.image
        view.clipsToBounds = true
        view.image = UIImage(resource: .divan)
        return view
    }()
    
    private lazy var imageContainer: UIView = {
        let view = UIView()
        view.addSubviews(imageView, likeBG)
        return view
    }()
    
    private lazy var likeBG: BlurredIconBackground = {
        let bg = BlurredIconBackground(cornerRadius: Metrics.Sizes.likeButton / 2)
        bg.embed(favoriteButton)
        return bg
    }()
    
    private lazy var titleLabel: UILabel = {
        Self.makeLabel(
            font: Metrics.Fonts.title,
            color: .label,
            lines: 0
        )
    }()
    
    private lazy var descriptionLabel: UILabel = {
        Self.makeLabel(
            font: Metrics.Fonts.description,
            color: .secondaryLabel,
            lines: 0
        )
    }()
    
    private lazy var priceLabel: UILabel = {
        Self.makeLabel(
            font: Metrics.Fonts.price,
            color: .label,
            lines: 1
        )
    }()
    
    /// Ряд под ценой для маленькой кнопки корзины / счётчика
    private lazy var controlsRow: UIView = {
        let view = UIView()
        view.addSubview(addToCartButton)
        return view
    }()
    
    // MARK: - Initialization
    
    init(viewModel: ProductDetailsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupHierarchy()
        setupLayout()
        setupActions()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
}

// MARK: - Setup

private extension ProductDetailsViewController {
    func setupNavigationBar() {
        setupNavigationBarWithNavLeftItem(
            action: #selector(backTapped),
            largeTitleDisplayMode: .never,
            prefersLargeTitles: false
        )
    }
    
    func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    func setupHierarchy() {
        scrollView.addSubview(contentStack)
        view.addSubviews(scrollView)
    }
    
    func setupLayout() {
        prepareForAutoLayout()
        setupImageSectionConstraints()
        setupControlsRowConstraints()
        setupScrollAndContentConstraints()
    }
    
    func setupActions() {
        addToCartButton.onTap(self, action: #selector(addToCartTapped))
        favoriteButton.onTap(self, action: #selector(favoriteTapped))
    }
}

// MARK: - Layout

private extension ProductDetailsViewController {
    func prepareForAutoLayout() {
        [scrollView,
         contentStack,
         imageContainer,
         imageView,
         likeBG,
         controlsRow,
         addToCartButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupImageSectionConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(
                equalTo: imageContainer.topAnchor
            ),
            imageView.leadingAnchor.constraint(
                equalTo: imageContainer.leadingAnchor
            ),
            imageView.trailingAnchor.constraint(
                equalTo: imageContainer.trailingAnchor
            ),
            imageView.bottomAnchor.constraint(
                equalTo: imageContainer.bottomAnchor
            ),
            imageView.heightAnchor.constraint(
                equalTo: imageView.widthAnchor,
                multiplier: Metrics.Layout.imageAspect
            ),
            
            likeBG.topAnchor.constraint(
                equalTo: imageContainer.topAnchor,
                constant: Metrics.Spacing.likePadding
            ),
            likeBG.trailingAnchor.constraint(
                equalTo: imageContainer.trailingAnchor,
                constant: -Metrics.Spacing.likePadding
            ),
            likeBG.widthAnchor.constraint(
                equalToConstant: Metrics.Sizes.likeButton
            ),
            likeBG.heightAnchor.constraint(
                equalToConstant: Metrics.Sizes.likeButton
            )
        ])
    }
    
    func setupControlsRowConstraints() {
        NSLayoutConstraint.activate([
            addToCartButton.leadingAnchor.constraint(
                equalTo: controlsRow.leadingAnchor
            ),
            addToCartButton.topAnchor.constraint(
                equalTo: controlsRow.topAnchor
            ),
            addToCartButton.bottomAnchor.constraint(
                equalTo: controlsRow.bottomAnchor
            )
        ])
    }
    
    func setupScrollAndContentConstraints() {
        NSLayoutConstraint.activate([
            // scroll
            scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            scrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            scrollView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
            
            // content
            contentStack.topAnchor.constraint(
                equalTo: scrollView.topAnchor,
                constant: Metrics.Insets.verticalTop
            ),
            contentStack.leadingAnchor.constraint(
                equalTo: scrollView.leadingAnchor,
                constant: Metrics.Insets.horizontal
            ),
            contentStack.trailingAnchor.constraint(
                equalTo: scrollView.trailingAnchor,
                constant: -Metrics.Insets.horizontal
            ),
            contentStack.bottomAnchor.constraint(
                equalTo: scrollView.bottomAnchor,
                constant: -Metrics.Insets.verticalBottom
            ),
            contentStack.widthAnchor.constraint(
                equalTo: scrollView.widthAnchor,
                constant: -(Metrics.Insets.horizontal * 2)
            )
        ])
    }
}

// MARK: - Configure

private extension ProductDetailsViewController {
    func configure() {
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        priceLabel.text = viewModel.priceText
    }
}

// MARK: - Actions

private extension ProductDetailsViewController {
    @objc func backTapped() {
        onBack?()
    }
    
    @objc func addToCartTapped() {
        isInCart.toggle()
        addToCartButton.setInCart(isInCart, animated: true)
        addToCartButton.pulse()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    @objc func favoriteTapped() {
        isFavorite.toggle()
        favoriteButton.setFavorite(isFavorite, animated: true)
        favoriteButton.pulse()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

// MARK: - Helpers

private extension ProductDetailsViewController {
    static func makeLabel(
        font: UIFont,
        color: UIColor,
        lines: Int,
        alignment: NSTextAlignment = .natural
    ) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = color
        label.numberOfLines = lines
        label.textAlignment = alignment
        return label
    }
}
