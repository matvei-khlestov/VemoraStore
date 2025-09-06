//
//  CartCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.09.2025.
//


import UIKit

protocol CartCellDelegate: AnyObject {
    /// Вызывается при изменении количества (после каждого тапа −/+)
    func cartCell(_ cell: CartCell, didChangeQuantity quantity: Int)
    /// Тап по кнопке удаления
    func cartCellDidTapDelete(_ cell: CartCell)
}

final class CartCell: UITableViewCell {

    static let reuseId = "CartCell"

    weak var delegate: CartCellDelegate?

    // MARK: - State
    private var quantity: Int = 1 {
        didSet {
            quantityLabel.text = "\(quantity)"
            minusButton.isEnabled = quantity > 1
        }
    }

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

    // MARK: - Qty pill (капсула − 1 +)
    private let qtyContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = true
        return v
    }()

    private lazy var minusButton: UIButton = {
        var conf = UIButton.Configuration.plain()
        conf.image = UIImage(systemName: "minus")
        conf.baseForegroundColor = UIColor(named: "AppAccent") ?? .systemPurple
        conf.contentInsets = .init(top: 6, leading: 10, bottom: 6, trailing: 10)
        let b = UIButton(configuration: conf)
        b.addTarget(self, action: #selector(decreaseTapped), for: .touchUpInside)
        return b
    }()

    private let quantityLabel: UILabel = {
        let l = UILabel()
        l.text = "1"
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = .label
        l.setContentHuggingPriority(.required, for: .horizontal)
        l.setContentCompressionResistancePriority(.required, for: .horizontal)
        return l
    }()

    private lazy var plusButton: UIButton = {
        var conf = UIButton.Configuration.plain()
        conf.image = UIImage(systemName: "plus")
        conf.baseForegroundColor = UIColor(named: "AppAccent") ?? .systemPurple
        conf.contentInsets = .init(top: 6, leading: 10, bottom: 6, trailing: 10)
        let b = UIButton(configuration: conf)
        b.addTarget(self, action: #selector(increaseTapped), for: .touchUpInside)
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
    /// Горизонтальная строка действий: счётчик слева + удалить справа
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
        setQuantity(1, notify: false)
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
            thumbImageView.widthAnchor.constraint(equalToConstant: 96)
        ])
        let thumbHeight = thumbImageView.heightAnchor.constraint(equalToConstant: 96)
        thumbHeight.priority = .defaultHigh
        thumbHeight.isActive = true

        // Правый вертикальный стек
        rightStack.axis = .vertical
        rightStack.spacing = 8
        rightStack.alignment = .fill
        rightStack.distribution = .fill
        rightStack.translatesAutoresizingMaskIntoConstraints = false

        rightStack.addArrangedSubview(categoryLabel)
        rightStack.addArrangedSubview(titleLabel)
        rightStack.addArrangedSubview(priceLabel)

        // Счётчик
        qtyContainer.translatesAutoresizingMaskIntoConstraints = false
        qtyContainer.heightAnchor.constraint(equalToConstant: 32).isActive = true

        qtyContainer.addSubview(minusButton)
        qtyContainer.addSubview(quantityLabel)
        qtyContainer.addSubview(plusButton)

        [minusButton, quantityLabel, plusButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            minusButton.leadingAnchor.constraint(equalTo: qtyContainer.leadingAnchor),
            minusButton.topAnchor.constraint(equalTo: qtyContainer.topAnchor),
            minusButton.bottomAnchor.constraint(equalTo: qtyContainer.bottomAnchor),

            plusButton.trailingAnchor.constraint(equalTo: qtyContainer.trailingAnchor),
            plusButton.topAnchor.constraint(equalTo: qtyContainer.topAnchor),
            plusButton.bottomAnchor.constraint(equalTo: qtyContainer.bottomAnchor),

            quantityLabel.centerXAnchor.constraint(equalTo: qtyContainer.centerXAnchor),
            quantityLabel.centerYAnchor.constraint(equalTo: qtyContainer.centerYAnchor),

            // Чуть компактнее ширина капсулы
            qtyContainer.widthAnchor.constraint(equalToConstant: 100)
        ])

        // Строка действий: счетчик слева, delete справа
        actionsRow.axis = .horizontal
        actionsRow.alignment = .center
        actionsRow.distribution = .fill
        actionsRow.spacing = 8

        let spacer = UIView()
        actionsRow.addArrangedSubview(qtyContainer)
        actionsRow.addArrangedSubview(spacer)
        actionsRow.addArrangedSubview(deleteButton)

        rightStack.addArrangedSubview(actionsRow)

        contentView.addSubview(rightStack)
        NSLayoutConstraint.activate([
            rightStack.leadingAnchor.constraint(equalTo: thumbImageView.trailingAnchor, constant: 12),
            rightStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            rightStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            rightStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor),

            // чтобы изображение не «выпирало» вниз
            thumbImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])

        // Приоритеты
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        priceLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        categoryLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    // В CartCell.swift
    func configure(with product: Product, quantity: Int) {
        titleLabel.text = product.name
        categoryLabel.text = product.categoryId
        priceLabel.text = String(format: "$%.2f", product.price)
        thumbImageView.image = UIImage(resource: .divan)
        setQuantity(quantity, notify: false)
    }

    func setQuantity(_ value: Int, notify: Bool = true) {
        quantity = max(1, value)
        if notify { delegate?.cartCell(self, didChangeQuantity: quantity) }
    }

    // MARK: - Actions
    @objc private func decreaseTapped() {
        guard quantity > 1 else { return }
        quantity -= 1
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        delegate?.cartCell(self, didChangeQuantity: quantity)
    }

    @objc private func increaseTapped() {
        quantity += 1
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        delegate?.cartCell(self, didChangeQuantity: quantity)
    }

    @objc private func deleteTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        deleteButton.pulse()
        delegate?.cartCellDidTapDelete(self)
    }
}
