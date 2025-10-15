//
//  BadgeView.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 18.09.2025.
//

import UIKit

final class BadgeView: UIView {
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let vertical: CGFloat = 6
            static let horizontal: CGFloat = 10
        }
        enum Sizes {
            static let cornerRadius: CGFloat = 10
        }
        enum Fonts {
            static let label: UIFont = .systemFont(ofSize: 12, weight: .semibold)
        }
    }
    
    // MARK: - UI
    
    private let label: UILabel = {
        let l = UILabel()
        l.font = Metrics.Fonts.label
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - API
    
    func configure(text: String, color: UIColor) {
        label.text = text
        backgroundColor = color
    }
}

// MARK: - Setup

private extension BadgeView {
    func setupView() {
        addSubview(label)
        backgroundColor = .systemGray
        layer.cornerRadius = Metrics.Sizes.cornerRadius
        layer.masksToBounds = true
    }
    
    func setupConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(
                equalTo: topAnchor,
                constant: Metrics.Insets.vertical
            ),
            label.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -Metrics.Insets.vertical
            ),
            label.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metrics.Insets.horizontal
            ),
            label.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metrics.Insets.horizontal
            )
        ])
    }
}
