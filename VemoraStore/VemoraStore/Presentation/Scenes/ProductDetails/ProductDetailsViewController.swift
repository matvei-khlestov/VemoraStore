//
//  ProductDetailsViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit

final class ProductDetailsViewController: UIViewController {

    // MARK: - Public callbacks
    var onCheckout: (() -> Void)?

    // MARK: - Deps
    private let viewModel: ProductDetailsViewModel

    // MARK: - State
    private var isFavorite = false
    private var quantity = 0 {
        didSet {
            quantityLabel.text = "\(quantity)"
            minusButton.isEnabled = quantity > 1
        }
    }

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .secondarySystemBackground
        iv.layer.cornerRadius = 12
        iv.clipsToBounds = true
        iv.image = UIImage(resource: .divan) // заглушка
        return iv
    }()

    private lazy var favoriteButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "heart"), for: .normal)
        b.tintColor = .brightPurple
        b.backgroundColor = .systemBackground
        b.layer.cornerRadius = 16
        b.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        return b
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 0
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()

    /// Ряд под ценой для маленькой кнопки корзины / счётчика
    private let controlsRow = UIView()

    private lazy var addToCartButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = nil // только иконка
        config.image = UIImage(systemName: "cart.fill.badge.plus")
        config.baseBackgroundColor = .brightPurple
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        let btn = UIButton(configuration: config)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 50).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var checkoutButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "К оформлению"
        config.image = UIImage(systemName: "creditcard.fill")
        config.imagePlacement = .trailing
        config.imagePadding = 12
        config.baseBackgroundColor = .systemOrange
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.contentInsets = .init(top: 10, leading: 16, bottom: 10, trailing: 16)
        let btn = UIButton(configuration: config)
        btn.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
        return btn
    }()

    // MARK: - Qty pill (капсула − 1 +)
    private let qtyContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 22
        v.layer.masksToBounds = true
        return v
    }()

    private lazy var minusButton: UIButton = {
        var conf = UIButton.Configuration.plain()
        conf.image = UIImage(systemName: "minus")
        conf.baseForegroundColor = .brightPurple
        conf.contentInsets = .init(top: 10, leading: 16, bottom: 10, trailing: 16)
        let b = UIButton(configuration: conf)
        b.addTarget(self, action: #selector(decreaseTapped), for: .touchUpInside)
        return b
    }()

    private let quantityLabel: UILabel = {
        let l = UILabel()
        l.text = "1"
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .label
        return l
    }()

    private lazy var plusButton: UIButton = {
        var conf = UIButton.Configuration.plain()
        conf.image = UIImage(systemName: "plus")
        conf.baseForegroundColor = .brightPurple
        conf.contentInsets = .init(top: 10, leading: 16, bottom: 10, trailing: 16)
        let b = UIButton(configuration: conf)
        b.addTarget(self, action: #selector(increaseTapped), for: .touchUpInside)
        return b
    }()

    // MARK: - Init
    init(viewModel: ProductDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        configure()
    }

    // MARK: - Setup
    private func setupLayout() {
        contentStack.axis = .vertical
        contentStack.spacing = 16

        // Картинка + «лайк» в правом верхнем углу
        let imageContainer = UIView()
        imageContainer.addSubview(imageView)

        // Небольшой «стеклянный» фон под иконкой лайка
        let likeBG = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
        likeBG.layer.cornerRadius = 18
        likeBG.clipsToBounds = true
        likeBG.contentView.addSubview(favoriteButton)
        imageContainer.addSubview(likeBG)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        likeBG.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),
            // Соотношение сторон 4:3
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 3.0/4.0),

            likeBG.topAnchor.constraint(equalTo: imageContainer.topAnchor, constant: 12),
            likeBG.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor, constant: -12),
            likeBG.widthAnchor.constraint(equalToConstant: 36),
            likeBG.heightAnchor.constraint(equalToConstant: 36),

            favoriteButton.centerXAnchor.constraint(equalTo: likeBG.centerXAnchor),
            favoriteButton.centerYAnchor.constraint(equalTo: likeBG.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 26),
            favoriteButton.heightAnchor.constraint(equalToConstant: 26)
        ])

        // Ряд под ценой: слева маленькая кнопка корзины или капсула количества
        controlsRow.translatesAutoresizingMaskIntoConstraints = false
        qtyContainer.translatesAutoresizingMaskIntoConstraints = false
        qtyContainer.isHidden = true

        controlsRow.addSubview(qtyContainer)
        controlsRow.addSubview(addToCartButton)

        // Внутренности капсулы
        qtyContainer.addSubview(minusButton)
        qtyContainer.addSubview(quantityLabel)
        qtyContainer.addSubview(plusButton)
        [minusButton, quantityLabel, plusButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            // controlsRow занимает всю ширину, фиксируем высоту по содержимому
            controlsRow.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),

            // Кнопка корзины — слева и по центру
            addToCartButton.leadingAnchor.constraint(equalTo: controlsRow.leadingAnchor),
            addToCartButton.centerYAnchor.constraint(equalTo: controlsRow.centerYAnchor),

            // Капсула количества — тоже слева (на месте кнопки), скрыта до первого тапа
            qtyContainer.leadingAnchor.constraint(equalTo: controlsRow.leadingAnchor),
            qtyContainer.centerYAnchor.constraint(equalTo: controlsRow.centerYAnchor),
            qtyContainer.heightAnchor.constraint(equalToConstant: 44),
            qtyContainer.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),

            // Внутри капсулы
            minusButton.leadingAnchor.constraint(equalTo: qtyContainer.leadingAnchor),
            minusButton.topAnchor.constraint(equalTo: qtyContainer.topAnchor),
            minusButton.bottomAnchor.constraint(equalTo: qtyContainer.bottomAnchor),

            plusButton.trailingAnchor.constraint(equalTo: qtyContainer.trailingAnchor),
            plusButton.topAnchor.constraint(equalTo: qtyContainer.topAnchor),
            plusButton.bottomAnchor.constraint(equalTo: qtyContainer.bottomAnchor),

            quantityLabel.centerXAnchor.constraint(equalTo: qtyContainer.centerXAnchor),
            quantityLabel.centerYAnchor.constraint(equalTo: qtyContainer.centerYAnchor)
        ])

        // Собираем экран
        [imageContainer, titleLabel, descriptionLabel, priceLabel, controlsRow]
            .forEach { contentStack.addArrangedSubview($0) }

        scrollView.addSubview(contentStack)
        view.addSubview(scrollView)
        view.addSubview(checkoutButton)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        checkoutButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),

            checkoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            checkoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            checkoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            checkoutButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func configure() {
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        priceLabel.text = viewModel.priceText
    }

    // MARK: - Actions
    @objc private func addToCartTapped() {
        if qtyContainer.isHidden {
            quantity = 1
            qtyContainer.isHidden = false
            addToCartButton.isHidden = true
            // viewModel.addToCart(quantity: quantity)
        }
    }

    @objc private func checkoutTapped() {
        onCheckout?()
    }

    @objc private func favoriteTapped() {
        isFavorite.toggle()
        favoriteButton.setImage(
            UIImage(systemName: isFavorite ? "heart.fill" : "heart"),
            for: .normal
        )

        // лёгкая пульсация
        favoriteButton.pulse()
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    @objc private func decreaseTapped() {
        guard quantity > 1 else { return }
        quantity -= 1
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        // viewModel.updateQuantity(quantity)
    }

    @objc private func increaseTapped() {
        quantity += 1
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        // viewModel.updateQuantity(quantity)
    }
}
