//
//  AboutViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import UIKit

final class AboutViewController: UIViewController {
    
    // MARK: - Callbacks
    
    var onBack: (() -> Void)?
    
    // MARK: - UI
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 20
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 24, left: 16, bottom: 24, right: 16)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var brandLogoView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .vemora))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var introLabel: UILabel = {
        let label = UILabel()
        label.text = "Vemora — современный магазин мебели и товаров для дома, где каждая деталь создана с заботой о вашем комфорте. Мы верим, что уют начинается с правильной атмосферы, а атмосфера — с качественной мебели, которая отражает ваш стиль и характер."
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var bulletsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        buildLayout()
        setupConstraints()
        populateBullets()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        title = "О нас"
        navigationItem.leftBarButtonItem = .backItem(
            target: self,
            action: #selector(backTapped),
            tintColor: .brightPurple
        )
    }
    
    // MARK: - Layout
    
    private func buildLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        // Brand logo
        contentStack.addArrangedSubview(brandLogoView)
        NSLayoutConstraint.activate([
            brandLogoView.heightAnchor.constraint(equalToConstant: 300),
            brandLogoView.leadingAnchor.constraint(equalTo: contentStack.layoutMarginsGuide.leadingAnchor),
            brandLogoView.trailingAnchor.constraint(equalTo: contentStack.layoutMarginsGuide.trailingAnchor)
        ])
        
        // Вступительный текст
        contentStack.addArrangedSubview(introLabel)
        
        // Блок преимуществ (буллеты)
        contentStack.addArrangedSubview(bulletsStack)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // scrollView to edges
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            // contentStack inside scrollView
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
        ])
        
        // Выравнивание ширины контента по фрейму скролла (учитывая layoutMargins у contentStack)
        // Здесь ничего дополнительного не нужно: мы пинем stack к frameLayoutGuide по сторонам.
    }
    
    // MARK: - Data
    
    private func populateBullets() {
        bulletsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let items: [(String, String)] = [
            ("Качество и надёжность", "Мы работаем только с проверенными поставщиками и используем экологичные материалы, чтобы каждая покупка радовала вас долгие годы."),
            ("Дизайн и вдохновение", "Коллекции Vemora — это сочетание современных трендов и функциональности. От минимализма до классики — у нас найдётся решение для любого интерьера."),
            ("Доступность", "Регулярные акции, бонусная система и быстрая доставка помогают сэкономить без компромиссов в качестве."),
            ("Забота о клиентах", "Мы помогаем выбрать идеальный вариант, подскажем по уходу за мебелью и организуем удобную доставку и сборку.")
        ]
        
        items.forEach { title, subtitle in
            let row = makeBulletRow(title: title, subtitle: subtitle)
            bulletsStack.addArrangedSubview(row)
        }
    }
    
    private func makeBulletRow(title: String, subtitle: String) -> UIView {
        let containerView = UIStackView()
        containerView.axis = .horizontal
        containerView.alignment = .top
        containerView.spacing = 12
        
        let dotView = UIImageView(image: UIImage(systemName: "checkmark.seal.fill"))
        dotView.tintColor = .brightPurple
        dotView.contentMode = .scaleAspectFit
        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.widthAnchor.constraint(equalToConstant: 22).isActive = true
        dotView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        let labelsStack = UIStackView()
        labelsStack.axis = .vertical
        labelsStack.alignment = .fill
        labelsStack.spacing = 4
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        
        labelsStack.addArrangedSubview(titleLabel)
        labelsStack.addArrangedSubview(subtitleLabel)
        
        containerView.addArrangedSubview(dotView)
        containerView.addArrangedSubview(labelsStack)
        return containerView
    }
    
    // MARK: - Actions
    
    @objc private func backTapped() {
        onBack?()
    }
}
