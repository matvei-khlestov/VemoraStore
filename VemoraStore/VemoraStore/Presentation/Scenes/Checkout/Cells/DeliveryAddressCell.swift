//
//  DeliveryAddressCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 10.09.2025.
//

import UIKit

final class DeliveryAddressCell: UITableViewCell {
    
    static let reuseId = "DeliveryAddressCell"
    
    // MARK: - UI
    
    private let iconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "truck.box.fill"))
        iv.tintColor = .brightPurple
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.widthAnchor.constraint(equalToConstant: 30).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 30).isActive = true
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
    
    private let separatorView: UIView = {
        let v = UIView()
        v.backgroundColor = .separator
        return v
    }()
    var showsSeparator: Bool = true {
        didSet { separatorView.isHidden = !showsSeparator }
    }
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground
        accessoryType = .disclosureIndicator
        setupLayout()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Layout
    
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
        
        contentView.addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        separatorView.isHidden = !showsSeparator
    }
    
    // MARK: - API
    
    /// Конфиг с двумя состояниями:
    /// - address == nil → показываем placeholder серым цветом
    /// - address != nil → показываем полный адрес обычным цветом
    func configure(address: String?, placeholder: String = "Указать адрес доставки") {
        if let address, !address.isEmpty {
            addressLabel.text = address
            addressLabel.textColor = .label
        } else {
            addressLabel.text = placeholder
            addressLabel.textColor = .secondaryLabel
        }
    }
}
