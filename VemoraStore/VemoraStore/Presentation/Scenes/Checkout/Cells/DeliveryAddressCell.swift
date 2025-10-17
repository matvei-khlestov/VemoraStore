//
//  DeliveryAddressCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 10.09.2025.
//

//
//  DeliveryAddressCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestов on 10.09.2025.
//

import UIKit

/// Ячейка таблицы, отображающая адрес доставки.
///
/// Содержит:
/// - иконку доставки (`truck.box.fill`);
/// - основной текст с адресом или плейсхолдером;
/// - нижний разделитель.
///
/// Используется в экране оформления заказа (`CheckoutViewController`)
/// для выбора или отображения текущего адреса доставки пользователя.
/// При нажатии на ячейку открывается экран выбора адреса.

final class DeliveryAddressCell: UITableViewCell {
    
    // MARK: - Reuse Id
    
    static let reuseId = String(describing: DeliveryAddressCell.self)
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 0
            static let verticalTop: CGFloat = 0
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
            static let icon: CGFloat = 30
        }
        
        enum Table {
            static let separatorHeight: CGFloat = 0.5
            static let separatorLeading: CGFloat = 16
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let addressPlaceholder = "Указать адрес доставки"
    }
    
    // MARK: - Symbols
    
    private enum Symbols {
        static let delivery = "truck.box.fill"
    }
    
    // MARK: - UI
    
    private let iconView: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: Symbols.delivery))
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
        setupAppearance()
        setupHierarchy()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension DeliveryAddressCell {
    func setupAppearance() {
        selectionStyle = .default
        accessoryType = .disclosureIndicator
    }
    
    func setupHierarchy() {
        hStack.addArrangedSubviews(
            iconView,
            addressLabel
        )
        contentView.addSubviews(
            hStack,
            separatorView
        )
    }
    
    func setupLayout() {
        prepareForAutoLayout()
        setupStackConstraints()
        setupIconConstraints()
        setupSeparatorConstraints()
        separatorView.isHidden = !showsSeparator
    }
}

// MARK: - Layout

private extension DeliveryAddressCell {
    func prepareForAutoLayout() {
        [hStack, separatorView, iconView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupStackConstraints() {
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            hStack.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            hStack.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            hStack.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            )
        ])
    }
    
    func setupIconConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(
                equalToConstant: Metrics.Sizes.icon
            ),
            iconView.heightAnchor.constraint(
                equalToConstant: Metrics.Sizes.icon
            )
        ])
    }
    
    func setupSeparatorConstraints() {
        NSLayoutConstraint.activate([
            separatorView.heightAnchor.constraint(
                equalToConstant: Metrics.Table.separatorHeight
            ),
            separatorView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Metrics.Table.separatorLeading
            ),
            separatorView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),
            separatorView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            )
        ])
    }
}

// MARK: - Configure API

extension DeliveryAddressCell {
    func configure(
        address: String?,
        placeholder: String = Texts.addressPlaceholder
    ) {
        if let address, !address.isEmpty {
            addressLabel.text = address
            addressLabel.textColor = .label
        } else {
            addressLabel.text = placeholder
            addressLabel.textColor = .secondaryLabel
        }
    }
}
