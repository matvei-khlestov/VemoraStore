//
//  CheckoutCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 10.09.2025.
//


import UIKit

final class CheckoutCell: UITableViewCell {

    static let reuseId = "CheckoutCell"

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
        l.textColor = .brightPurple
        l.setContentCompressionResistancePriority(.required, for: .vertical)
        return l
    }()

    private let quantityLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .medium)
        l.textColor = .secondaryLabel
        return l
    }()

    /// Вертикальный стек справа от картинки
    private let rightStack = UIStackView()

    /// Разделитель снизу
    private let separatorView: UIView = {
        let v = UIView()
        v.backgroundColor = .separator
        return v
    }()

    /// Controls bottom separator visibility
    var showsSeparator: Bool = true {
        didSet { separatorView.isHidden = !showsSeparator }
    }

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
        quantityLabel.text = nil
        showsSeparator = true
    }

    // MARK: - Layout
    private func setupLayout() {
        contentView.layoutMargins = .init(top: 12, left: 16, bottom: 12, right: 16)

        // Картинка слева
        contentView.addSubview(thumbImageView)
        thumbImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumbImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            thumbImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            thumbImageView.widthAnchor.constraint(equalToConstant: 110)
        ])
        let thumbHeight = thumbImageView.heightAnchor.constraint(equalToConstant: 110)
        thumbHeight.priority = .defaultHigh
        thumbHeight.isActive = true

        // Правый вертикальный стек
        rightStack.axis = .vertical
        rightStack.spacing = 6
        rightStack.alignment = .fill
        rightStack.distribution = .fill
        rightStack.translatesAutoresizingMaskIntoConstraints = false

        rightStack.addArrangedSubview(categoryLabel)
        rightStack.addArrangedSubview(titleLabel)
        rightStack.addArrangedSubview(priceLabel)
        rightStack.addArrangedSubview(quantityLabel)

        contentView.addSubview(rightStack)
        NSLayoutConstraint.activate([
            rightStack.leadingAnchor.constraint(equalTo: thumbImageView.trailingAnchor, constant: 8),
            rightStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            rightStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            rightStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor),

            thumbImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])

        // Разделитель
        contentView.addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        separatorView.isHidden = !showsSeparator

        // Приоритеты
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        priceLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        categoryLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    // MARK: - API
    func configure(with product: ProductTest, quantity: Int) {
        titleLabel.text = product.name
        categoryLabel.text = product.categoryId
        priceLabel.text = String(format: "$%.2f", product.price)
        quantityLabel.text = "x\(quantity)"
        thumbImageView.image = UIImage(resource: .divan)
    }
}
