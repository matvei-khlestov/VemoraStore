//
//  PickupAddressCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 10.09.2025.
//

import UIKit

final class PickupAddressCell: UITableViewCell {
    
    // MARK: - Reuse Id
    
    static let reuseId = String(describing: PickupAddressCell.self)
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat   = 0
            static let verticalTop: CGFloat  = 0
            static let verticalBottom: CGFloat = 0
            
            static let content: NSDirectionalEdgeInsets = .init(
                top: 15, leading: 16, bottom: 15, trailing: 16
            )
        }
        
        enum Spacing {
            static let inlineElements: CGFloat = 12
        }
        
        enum Fonts {
            static let address: UIFont = .systemFont(ofSize: 15, weight: .regular)
        }
        
        enum Sizes {
            static let icon: CGFloat = 28
        }
    }
    
    // MARK: - Symbols
    
    private enum Symbols {
        static let storefront = "storefront.fill"
    }
    
    // MARK: - UI
    
    private let iconView: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: Symbols.storefront))
        v.contentMode = .scaleAspectFit
        v.tintColor = .brightPurple
        return v
    }()
    
    private let addressLabel: UILabel = {
        let l = UILabel()
        l.font = Metrics.Fonts.address
        l.textColor = .label
        l.numberOfLines = 0
        return l
    }()
    
    private let hStack: UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        v.alignment = .center
        v.spacing = Metrics.Spacing.inlineElements
        v.isLayoutMarginsRelativeArrangement = true
        v.directionalLayoutMargins = Metrics.Insets.content
        return v
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupAppearance()
        setupHierarchy()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension PickupAddressCell {
    func setupAppearance() {
        selectionStyle = .none
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground
    }
    
    func setupHierarchy() {
        hStack.addArrangedSubviews(iconView, addressLabel)
        contentView.addSubview(hStack)
    }
    
    func setupLayout() {
        [hStack, iconView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(
                equalTo: contentView.topAnchor)
            ,
            hStack.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            hStack.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            hStack.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            ),
            
            iconView.widthAnchor.constraint(
                equalToConstant: Metrics.Sizes.icon
            ),
            iconView.heightAnchor.constraint(
                equalToConstant: Metrics.Sizes.icon
            )
        ])
    }
}

// MARK: - Configure API

extension PickupAddressCell {
    func configure(address: String, icon: UIImage? = nil) {
        addressLabel.text = address
        if let icon { iconView.image = icon }
    }
}
