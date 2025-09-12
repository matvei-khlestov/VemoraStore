//
//  PickupAddressCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 10.09.2025.
//

import UIKit

final class PickupAddressCell: UITableViewCell {
    
    static let reuseId = "PickupAddressCell"

    private let iconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "storefront.fill"))
        iv.tintColor = .brightPurple
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.widthAnchor.constraint(equalToConstant: 28).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 28).isActive = true
        return iv
    }()

    private let addressLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = .label
        l.numberOfLines = 0
        return l
    }()

    private let hStack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .default
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground
        setupLayout()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLayout() {
        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.spacing = 12
        hStack.isLayoutMarginsRelativeArrangement = true
        hStack.layoutMargins = .init(top: 15, left: 16, bottom: 15, right: 16)

        hStack.addArrangedSubview(iconView)
        hStack.addArrangedSubview(addressLabel)

        contentView.addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func configure(address: String, icon: UIImage? = nil) {
        addressLabel.text = address
        if let icon { iconView.image = icon }
    }
}
