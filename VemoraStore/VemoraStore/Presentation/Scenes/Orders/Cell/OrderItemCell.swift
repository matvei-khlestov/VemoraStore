//
//  OrderItemCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 18.09.2025.
//

import UIKit

final class OrderItemCell: UITableViewCell {
    
    static let reuseId = "OrderItemCell"
    
    // MARK: - UI (configured in closures)
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
        l.numberOfLines = 0
        l.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return l
    }()
    
    private let categoryLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
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
    
    private let rightStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 6
        v.alignment = .fill
        v.distribution = .fill
        return v
    }()
    
    private let separatorView: UIView = {
        let v = UIView()
        v.backgroundColor = .separator
        return v
    }()
    
    var showsSeparator: Bool = true { didSet { separatorView.isHidden = !showsSeparator } }
    
    // Доп. блоки
    private let metaStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 4
        v.alignment = .fill
        v.distribution = .fill
        return v
    }()
    
    private let addressLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.setContentCompressionResistancePriority(.required, for: .vertical)
        return l
    }()
    
    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .secondaryLabel
        return l
    }()
    
    private let paymentLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .medium)
        l.textColor = .secondaryLabel
        return l
    }()
    
    private let statusBadge: BadgeView = {
        let v = BadgeView()
        return v
    }()
    
    private let infoStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        return stack
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .systemBackground
        contentView.layoutMargins = .init(top: 12, left: 16, bottom: 12, right: 16)
        
        setupRightStack()
        setupMetaStack()
        setupHierarchy()
        setupConstraints()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbImageView.image = nil
        titleLabel.text = nil
        categoryLabel.text = nil
        priceLabel.text = nil
        quantityLabel.text = nil
        addressLabel.text = nil
        dateLabel.text = nil
        paymentLabel.text = nil
        showsSeparator = true
    }
    
    // MARK: - Setup subviews composition
    private func setupRightStack() {
        rightStack.addArrangedSubview(categoryLabel)
        rightStack.addArrangedSubview(titleLabel)
        rightStack.addArrangedSubview(priceLabel)
        rightStack.addArrangedSubview(quantityLabel)
    }
    
    private func setupMetaStack() {
        metaStack.addArrangedSubview(addressLabel)
        metaStack.addArrangedSubview(dateLabel)
        metaStack.addArrangedSubview(paymentLabel)
    }
    
    private func setupHierarchy() {
        contentView.addSubview(thumbImageView)
        contentView.addSubview(rightStack)
        
        infoStack.addArrangedSubview(metaStack)
        infoStack.addArrangedSubview(statusBadge)
        
        contentView.addSubview(infoStack)
        contentView.addSubview(separatorView)
    }
    
    // MARK: - Constraints/Layout only
    private func setupConstraints() {
        // Disable autoresizing masks
        [
            thumbImageView, rightStack, infoStack, separatorView
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            // Left image
            thumbImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            thumbImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            thumbImageView.widthAnchor.constraint(equalToConstant: 110),
            thumbImageView.heightAnchor.constraint(equalToConstant: 110),
            
            // Right column
            rightStack.leadingAnchor.constraint(equalTo: thumbImageView.trailingAnchor, constant: 8),
            rightStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            rightStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            
            // Meta + badge below right column
            infoStack.leadingAnchor.constraint(equalTo: rightStack.leadingAnchor),
            infoStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            infoStack.topAnchor.constraint(equalTo: rightStack.bottomAnchor, constant: 8),
            infoStack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            
            // Separator
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // MARK: - API
    func configure(item: OrderItem, order: OrderEntity) {
        titleLabel.text = item.product.name
        categoryLabel.text = item.product.categoryId
        priceLabel.text = String(format: "$%.2f", item.product.price)
        quantityLabel.text = "x\(item.quantity)"
        thumbImageView.image = UIImage(resource: .divan)
        
        addressLabel.text = "Адрес: \(order.receiveAddress)"
        dateLabel.text = "Дата создания: \(order.createdAt.description)"
        paymentLabel.text = "Оплата: \(order.paymentMethod)"
        
        // Badge
        let color: UIColor = {
            switch order.status {
            case .assembling: return .systemOrange
            case .ready:      return .systemBlue
            case .delivering: return .systemTeal
            case .delivered:  return .systemGreen
            case .cancelled:  return .systemRed
            }
        }()
        statusBadge.configure(text: order.status.badgeText, color: color)
    }
}
