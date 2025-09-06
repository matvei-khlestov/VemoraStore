//
//  FavoritesCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 05.09.2025.
//

import UIKit

protocol FavoritesCellDelegate: AnyObject {
    func favoritesCellDidTapCart(_ cell: FavoritesCell)
    func favoritesCellDidTapDelete(_ cell: FavoritesCell)
}

final class FavoritesCell: UITableViewCell {
    
    static let reuseId = "FavoritesCell"
    
    weak var delegate: FavoritesCellDelegate?
    
    // MARK: - State
    private var isInCart: Bool = false
    
    // MARK: - UI
    private let thumbImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .label
        l.numberOfLines = 2
        return l
    }()
    
    private let categoryLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = .secondaryLabel
        l.setContentCompressionResistancePriority(.required, for: .vertical)
        return l
    }()
    
    private let priceLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = UIColor(named: "AppAccent") ?? .systemPurple
        l.setContentCompressionResistancePriority(.required, for: .vertical)
        return l
    }()
    
    private lazy var cartButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "cart.badge.plus"), for: .normal)
        b.tintColor = UIColor(named: "AppAccent") ?? .systemPurple
        b.backgroundColor = .systemBackground
        b.layer.cornerRadius = 16
        b.addTarget(self, action: #selector(cartTapped), for: .touchUpInside)
        // компактная квадратная
        b.widthAnchor.constraint(equalToConstant: 32).isActive = true
        b.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return b
    }()
    
    private lazy var deleteButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "trash"), for: .normal)
        b.tintColor = .systemRed
        b.backgroundColor = .systemBackground
        b.layer.cornerRadius = 16
        b.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        b.widthAnchor.constraint(equalToConstant: 32).isActive = true
        b.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return b
    }()
    
    /// Вертикальный стек справа от картинки
    private let rightStack = UIStackView()
    
    /// Горизонтальная строка действий под текстом справа: корзина слева
    private let actionsRow = UIStackView()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .systemBackground
        setupLayout()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbImageView.image = nil
        titleLabel.text = nil
        categoryLabel.text = nil
        priceLabel.text = nil
        setInCart(false, animated: false)
    }
    
    // MARK: - Layout
    private func setupLayout() {
        contentView.layoutMargins = .init(top: 12, left: 16, bottom: 12, right: 16)
        
        // Картинка слева
        contentView.addSubview(thumbImageView)
        thumbImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumbImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            thumbImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            thumbImageView.widthAnchor.constraint(equalToConstant: 96),
            thumbImageView.heightAnchor.constraint(equalToConstant: 96)
        ])
        
        // Правый вертикальный стек
        rightStack.axis = .vertical
        rightStack.spacing = 6
        rightStack.alignment = .fill
        rightStack.distribution = .fill
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Контент справа (сверху вниз): категория, цена, заголовок
        rightStack.addArrangedSubview(categoryLabel)
        rightStack.addArrangedSubview(titleLabel)
        rightStack.addArrangedSubview(priceLabel)
        
        // Строка действий: корзина слева + спейсер
        actionsRow.axis = .horizontal
        actionsRow.alignment = .center
        actionsRow.distribution = .fill
        actionsRow.spacing = 8
        let spacer = UIView()
        actionsRow.addArrangedSubview(cartButton)
        actionsRow.addArrangedSubview(deleteButton)
        actionsRow.addArrangedSubview(spacer)
        
        rightStack.addArrangedSubview(actionsRow)
        
        contentView.addSubview(rightStack)
        NSLayoutConstraint.activate([
            rightStack.leadingAnchor.constraint(equalTo: thumbImageView.trailingAnchor, constant: 12),
            rightStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            rightStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            // важная нижняя привязка, чтобы ячейка корректно считала высоту
            rightStack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            
            // картинка не должна выбивать низ
            thumbImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
        
        // Приоритеты, чтобы заголовок не давил низ
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        priceLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        categoryLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    // MARK: - API
    func configure(with product: Product, isInCart: Bool = false) {
        titleLabel.text = product.name
        categoryLabel.text = product.categoryId
        priceLabel.text = String(format: "$%.2f", product.price)
        
        // Загрузчик изображений по желанию:
        // thumbImageView.kf.setImage(with: product.image)
        thumbImageView.image = UIImage(resource: .divan)
        
        setInCart(isInCart, animated: false)
    }
    
    /// Изменение состояния корзины снаружи (например, после ответа сервиса)
    func setInCart(_ value: Bool, animated: Bool = true) {
        isInCart = value
        let iconName = value ? "cart.fill.badge.minus" : "cart.badge.plus"
        let img = UIImage(systemName: iconName)
        
        let apply = { self.cartButton.setImage(img, for: .normal) }
        if animated {
            UIView.transition(with: cartButton, duration: 0.18, options: .transitionCrossDissolve, animations: apply)
        } else {
            apply()
        }
    }
    
    // MARK: - Actions
    @objc private func cartTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        setInCart(!isInCart, animated: true)
        cartButton.pulse()
        delegate?.favoritesCellDidTapCart(self)
    }
    
    @objc private func deleteTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        deleteButton.pulse()
        delegate?.favoritesCellDidTapDelete(self)
    }
}
