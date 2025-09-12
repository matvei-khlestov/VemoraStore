//
//  PaymentMethodCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 10.09.2025.
//

import UIKit

final class PaymentMethodCell: UITableViewCell {
    
    static let reuseId = "PaymentMethodCell"

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Как оплатить заказ?"
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textColor = .label
        return l
    }()

    private let pillView: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 10
        v.layer.borderWidth = 1.2
        v.layer.borderColor = UIColor.brightPurple.cgColor
        return v
    }()

    private let pillLabel: UILabel = {
        let l = UILabel()
        l.text = "При получении"
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = .label
        return l
    }()

    private let rootStack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground
        setupLayout()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout() {
        
        let pillContent = UIStackView(arrangedSubviews: [pillLabel])
        pillContent.axis = .horizontal
        pillContent.alignment = .center
        pillContent.isLayoutMarginsRelativeArrangement = true
        pillContent.layoutMargins = .init(top: 10, left: 12, bottom: 10, right: 12)

        pillView.addSubview(pillContent)
        pillContent.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pillContent.topAnchor.constraint(equalTo: pillView.topAnchor),
            pillContent.leadingAnchor.constraint(equalTo: pillView.leadingAnchor),
            pillContent.trailingAnchor.constraint(equalTo: pillView.trailingAnchor),
            pillContent.bottomAnchor.constraint(equalTo: pillView.bottomAnchor)
        ])

        rootStack.axis = .vertical
        rootStack.alignment = .leading
        rootStack.spacing = 8
        rootStack.isLayoutMarginsRelativeArrangement = true
        rootStack.layoutMargins = .init(top: 15, left: 16, bottom: 15, right: 16)

        rootStack.addArrangedSubview(titleLabel)
        rootStack.addArrangedSubview(pillView)

        contentView.addSubview(rootStack)
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            rootStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            rootStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            rootStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func configure(title: String = "Как оплатить заказ?", method: String = "При получении") {
        titleLabel.text = title
        pillLabel.text = method
    }
}
