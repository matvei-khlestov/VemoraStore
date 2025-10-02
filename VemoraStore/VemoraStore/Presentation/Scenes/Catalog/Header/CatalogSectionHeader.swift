//
//  CatalogSectionHeader.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 04.09.2025.
//

import UIKit

final class CatalogSectionHeader: UICollectionReusableView {
    
    // MARK: - Reuse Identifier
    
    static let reuseId = String(describing: CatalogSectionHeader.self)
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 16
        }
        enum Fonts {
            static let title: UIFont = .systemFont(ofSize: 22, weight: .bold)
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let title = "Все товары"
    }
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.Fonts.title
        label.text = Texts.title
        return label
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension CatalogSectionHeader {
    func setupHierarchy() {
        addSubview(titleLabel)
    }
    
    func setupLayout() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metrics.Insets.horizontal
            ),
            titleLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingAnchor,
                constant: -Metrics.Insets.horizontal
            ),
            titleLabel.topAnchor.constraint(
                equalTo: topAnchor
            ),
            titleLabel.bottomAnchor.constraint(
                equalTo: bottomAnchor
            )
        ])
    }
}

