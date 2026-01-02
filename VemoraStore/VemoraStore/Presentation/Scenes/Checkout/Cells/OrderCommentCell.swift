//
//  OrderCommentCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.09.2025.
//

import UIKit

/// Ячейка таблицы, используемая в экране оформления заказа (`CheckoutViewController`)
/// для отображения или редактирования комментария к заказу.
///
/// Содержит:
/// - иконку комментария (`text.bubble.fill`);
/// - текст с введённым комментарием или плейсхолдер "Оставить комментарий";
/// - нижний разделитель.
///
/// При нажатии на ячейку открывается экран редактирования комментария.

final class OrderCommentCell: UITableViewCell {
    
    // MARK: - Reuse Id
    
    static let reuseId = String(describing: OrderCommentCell.self)
    
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
            static let comment: UIFont = .systemFont(ofSize: 15, weight: .regular)
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
        static let placeholder = "Оставить комментарий"
    }
    
    // MARK: - Symbols
    
    private enum Symbols {
        static let comment = "text.bubble.fill"
    }
    
    // MARK: - UI
    
    private let iconView: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: Symbols.comment))
        v.contentMode = .scaleAspectFit
        v.tintColor = .brightPurple
        return v
    }()
    
    private let commentLabel: UILabel = {
        let l = UILabel()
        l.font = Metrics.Fonts.comment
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.text = Texts.placeholder
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
    
    var showsSeparator: Bool = false {
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

private extension OrderCommentCell {
    func setupAppearance() {
        selectionStyle = .default
        accessoryType = .disclosureIndicator
    }
    
    func setupHierarchy() {
        hStack.addArrangedSubviews(iconView, commentLabel)
        contentView.addSubviews(hStack, separatorView)
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

private extension OrderCommentCell {
    func prepareForAutoLayout() {
        [hStack, iconView, separatorView].forEach {
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

extension OrderCommentCell {
    /// Если `comment == nil/empty` → плейсхолдер серым; иначе — текст обычным цветом.
    func configure(
        comment: String?,
        placeholder: String = Texts.placeholder
    ) {
        let text = comment?.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasText = (text?.isEmpty == false)
        commentLabel.text = hasText ? text : placeholder
        commentLabel.textColor = hasText ? .label : .secondaryLabel
    }
}
