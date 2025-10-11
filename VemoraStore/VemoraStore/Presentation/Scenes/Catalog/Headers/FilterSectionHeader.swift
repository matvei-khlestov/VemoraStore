//
//  FilterSectionHeader.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 10.10.2025.
//

import UIKit

/// Заголовок секции фильтра (например: «Категории», «Бренды», «Цена»).
final class FilterSectionHeader: UICollectionReusableView {
    
    // MARK: - Reuse Id
    
    static let reuseId = String(describing: FilterSectionHeader.self)
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Sizes {
            static let height: CGFloat = 36
            static let separatorHeight: CGFloat = 1 / UIScreen.main.scale
        }
        enum Insets {
            static let horizontal: CGFloat = 12
            static let vertical: CGFloat = 6
        }
        enum Fonts {
            static let title: UIFont = .systemFont(ofSize: 17, weight: .semibold)
        }
        enum Colors {
            static let title: UIColor = .label
            static let separator: UIColor = .separator
        }
    }
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = Metrics.Fonts.title
        l.textColor = Metrics.Colors.title
        l.numberOfLines = 1
        return l
    }()
    
    private let separatorView: UIView = {
        let v = UIView()
        v.backgroundColor = Metrics.Colors.separator
        return v
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
        setupHierarchy()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - API
    
    func setTitle(_ text: String) {
        titleLabel.text = text
    }
}

// MARK: - Setup

private extension FilterSectionHeader {
    func setupAppearance() {
        backgroundColor = .systemGroupedBackground
    }
    
    func setupHierarchy() {
        addSubviews(titleLabel, separatorView)
    }
    
    func setupLayout() {
        [titleLabel, separatorView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            
        }
        
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
                equalTo: topAnchor,
                constant: Metrics.Insets.vertical
            ),
            titleLabel.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -Metrics.Insets.vertical
            ),
            
            separatorView.heightAnchor.constraint(
                equalToConstant: Metrics.Sizes.separatorHeight
            ),
            separatorView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metrics.Insets.horizontal
            ),
            separatorView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metrics.Insets.horizontal
            ),
            separatorView.bottomAnchor.constraint(
                equalTo: bottomAnchor
            )
        ])
    }
}
