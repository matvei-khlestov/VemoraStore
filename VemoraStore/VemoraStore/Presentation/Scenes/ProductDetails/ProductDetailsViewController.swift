//
//  ProductDetailsViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit
import Combine
import Kingfisher

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
            static let favoriteSymbolPointSize: CGFloat = 20
            static let cartSymbolPointSize: CGFloat = 30
        }
        enum Corners {
            static let image: CGFloat = 12
        }
        enum Layout {
            static let imageAspect: CGFloat = 3.0 / 3.0
        }
    }
    
    // MARK: - State
    
    private var isFavorite = false
    private var bag = Set<AnyCancellable>()
    
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
    
    private lazy var productImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = Metrics.Corners.image
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var imageContainer: UIView = {
        let view = UIView()
        view.addSubviews(productImageView, favoriteButton)
        return view
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
        bindViewModel()
        configureInitial()
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
        view.backgroundColor = .tertiarySystemGroupedBackground
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
    
    func bindViewModel() {
        viewModel.productPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.renderFromViewModel()
            }
            .store(in: &bag)
        
        viewModel.isInCartPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] inCart in
                self?.addToCartButton.setInCart(inCart, animated: true)
            }
            .store(in: &bag)
    }
}

// MARK: - Layout

private extension ProductDetailsViewController {
    func prepareForAutoLayout() {
        [scrollView,
         contentStack,
         imageContainer,
         productImageView,
         favoriteButton,
         controlsRow,
         addToCartButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupImageSectionConstraints() {
        NSLayoutConstraint.activate([
            productImageView.topAnchor.constraint(
                equalTo: imageContainer.topAnchor
            ),
            productImageView.leadingAnchor.constraint(
                equalTo: imageContainer.leadingAnchor
            ),
            productImageView.trailingAnchor.constraint(
                equalTo: imageContainer.trailingAnchor
            ),
            productImageView.bottomAnchor.constraint(
                equalTo: imageContainer.bottomAnchor
            ),
            productImageView.heightAnchor.constraint(
                equalTo: productImageView.widthAnchor,
                multiplier: Metrics.Layout.imageAspect
            ),
            
            favoriteButton.topAnchor.constraint(
                equalTo: imageContainer.topAnchor,
                constant: Metrics.Spacing.likePadding
            ),
            favoriteButton.trailingAnchor.constraint(
                equalTo: imageContainer.trailingAnchor,
                constant: -Metrics.Spacing.likePadding
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
    func configureInitial() {
        let url = URL(string: viewModel.imageURL ?? "")
        productImageView.kf.setImage(with: url)
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        priceLabel.text = viewModel.priceText
        // начальное состояние избранного
        isFavorite = viewModel.isFavorite
        favoriteButton.setFavorite(isFavorite, animated: false)
        addToCartButton.setInCart(viewModel.currentIsInCart, animated: false)
    }
    
    func renderFromViewModel() {
        let url = URL(string: viewModel.imageURL ?? "")
        productImageView.kf.setImage(with: url)
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        priceLabel.text = viewModel.priceText
        // обновим избранное
        isFavorite = viewModel.isFavorite
        favoriteButton.setFavorite(isFavorite, animated: true)
    }
}

// MARK: - Actions

private extension ProductDetailsViewController {
    @objc func backTapped() {
        onBack?()
    }
    
    @objc func addToCartTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if viewModel.currentIsInCart {
            viewModel.removeFromCart()
        } else {
            viewModel.addToCart()
        }
        // Кнопка обновится из isInCartPublisher
        addToCartButton.pulse()
    }
    
    @objc func favoriteTapped() {
        viewModel.toggleFavorite()
        isFavorite = viewModel.isFavorite
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
