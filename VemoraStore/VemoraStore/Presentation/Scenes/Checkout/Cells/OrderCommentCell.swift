//
//  OrderCommentCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.09.2025.
//

import UIKit

final class OrderCommentCell: UITableViewCell {
    
    static let reuseId = "OrderCommentCell"
    
    // MARK: - UI
    
    private let iconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "text.bubble.fill"))
        iv.tintColor = .brightPurple
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.widthAnchor.constraint(equalToConstant: 30).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 30).isActive = true
        return iv
    }()
    
    private let commentLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.text = "Оставить комментарий"
        return l
    }()
    
    private let hStack = UIStackView()
    
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
        hStack.addArrangedSubview(commentLabel)
        
        contentView.addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            hStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    // MARK: - API
    
    /// Если `comment == nil` или пустой — показываем плейсхолдер серым.
    /// Иначе — показываем сам комментарий обычным цветом.
    func configure(comment: String?, placeholder: String = "Оставить комментарий") {
        if let text = comment, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            commentLabel.text = text
            commentLabel.textColor = .label
        } else {
            commentLabel.text = placeholder
            commentLabel.textColor = .secondaryLabel
        }
    }
}
