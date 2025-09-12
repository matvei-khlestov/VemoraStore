//
//  DeliveryInfoCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 10.09.2025.
//

import UIKit

final class DeliveryInfoCell: UITableViewCell {
    
    static let reuseId = "DeliveryInfoCell"

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Доставка Vemora Store"
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 13, weight: .medium)
        return l
    }()

    private let whenLabel: UILabel = {
        let l = UILabel()
        l.textColor = .label
        l.font = .systemFont(ofSize: 17, weight: .bold)
        return l
    }()

    private let costLabel: UILabel = {
        let l = UILabel()
        l.textColor = .systemGreen
        l.font = .systemFont(ofSize: 15, weight: .medium)
        return l
    }()

    private let vStack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground
        setupLayout()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout() {
        vStack.axis = .vertical
        vStack.alignment = .fill
        vStack.spacing = 8
        vStack.isLayoutMarginsRelativeArrangement = true
        vStack.layoutMargins = .init(top: 15, left: 16, bottom: 15, right: 16)

        vStack.addArrangedSubview(titleLabel)
        vStack.addArrangedSubview(whenLabel)
        vStack.addArrangedSubview(costLabel)

        contentView.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            vStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            vStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func configure(when: String, cost: String) {
        whenLabel.text = when
        costLabel.text = cost
    }
}
