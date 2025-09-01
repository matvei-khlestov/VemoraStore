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
    
    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.backgroundColor = .secondarySystemBackground
        iv.layer.cornerRadius = 12
        iv.clipsToBounds = true
        return iv
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
    
    private lazy var addToCartButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Добавить в корзину", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.backgroundColor = .systemBlue
        btn.tintColor = .white
        btn.layer.cornerRadius = 12
        btn.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var checkoutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Оформить заказ", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.backgroundColor = .systemGreen
        btn.tintColor = .white
        btn.layer.cornerRadius = 12
        btn.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
        return btn
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
        
        [imageView, titleLabel, descriptionLabel, priceLabel, addToCartButton, checkoutButton].forEach {
            contentStack.addArrangedSubview($0)
        }
        
        scrollView.addSubview(contentStack)
        view.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    private func configure() {
        // ⚡ Заглушка: пока просто используем свойства VM
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        priceLabel.text = viewModel.priceText
        // Если добавишь загрузку картинок через Kingfisher:
        // if let url = viewModel.imageURL { imageView.kf.setImage(with: url) }
    }
    
    // MARK: - Actions
    @objc private func addToCartTapped() {
        viewModel.addToCart()
    }
    
    @objc private func checkoutTapped() {
        onCheckout?()
    }
}
