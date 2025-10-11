//
//  CatalogSectionHeader.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 04.09.2025.
//

import UIKit

final class CatalogSectionHeader: UICollectionReusableView {
    
    // MARK: - Reuse Id
    
    static let reuseId = String(describing: CatalogSectionHeader.self)
    
    // MARK: - Callbacks
    
    var onFilterTap: (() -> Void)?
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 16
        }
        enum Fonts {
            static let title:  UIFont = .systemFont(ofSize: 22, weight: .bold)
            static let filter: UIFont = .systemFont(ofSize: 16, weight: .medium)
            static let badge:  UIFont = .systemFont(ofSize: 12, weight: .semibold)
        }
        enum Button {
            static let size: CGFloat = 20
            static let imageName = "line.3.horizontal.decrease"
            static let spacingToLabel: CGFloat = 6
            static let spacingToBadge: CGFloat = 6
        }
        enum Badge {
            static let minSide: CGFloat = 18
            static let contentH: CGFloat = 8
            static let contentV: CGFloat = 2
        }
        enum Spacing {
            static let horizontal: CGFloat = 8
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let title  = "Все товары"
        static let filter = "Фильтры"
    }
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.Fonts.title
        label.textColor = .label
        label.text = Texts.title
        return label
    }()
    
    private let filterButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(
            pointSize: Metrics.Button.size,
            weight: .regular
        )
        button.setImage(
            UIImage(
                systemName: Metrics.Button.imageName,
                withConfiguration: config
            ),
            for: .normal
        )
        button.tintColor = .brightPurple
        button.contentHorizontalAlignment = .center
        button.accessibilityLabel = Texts.filter
        return button
    }()
    
    private let filterLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.Fonts.filter
        label.textColor = .label
        label.text = Texts.filter
        return label
    }()
    
    private let badgeBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.isHidden = true
        return view
    }()
    
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.Fonts.badge
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let hStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = Metrics.Spacing.horizontal
        return stack
    }()
    
    private let spacer = UIView()
    
    private let filterContainer = UIView()
    
    // MARK: - Constraints (alternatives)
    
    private var badgeTrailingConstraint: NSLayoutConstraint?
    private var labelTrailingConstraint: NSLayoutConstraint?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
        setupHierarchy()
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Re-layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        badgeBackgroundView.layer.cornerRadius = badgeBackgroundView.bounds.height / 2
        badgeBackgroundView.clipsToBounds = true
    }
    
    // MARK: - Configure API
    
    /// Обновляет количество активных фильтров.
    /// При `count == 0` бейдж скрывается и лейбл «Фильтры» прижимается к правому краю.
    func setFilterCount(_ count: Int, animated: Bool = false) {
        let changes = { [weak self] in
            guard let self else { return }
            if count > 0 {
                badgeLabel.text = "\(count)"
                badgeBackgroundView.isHidden = false
                badgeTrailingConstraint?.isActive = true
                labelTrailingConstraint?.isActive = false
            } else {
                badgeLabel.text = nil
                badgeBackgroundView.isHidden = true
                badgeTrailingConstraint?.isActive = false
                labelTrailingConstraint?.isActive = true
            }
            self.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: changes)
        } else {
            changes()
        }
    }
}

// MARK: - Setup

private extension CatalogSectionHeader {
    func setupAppearance() {
        backgroundColor = .clear
    }
    
    func setupHierarchy() {
        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.spacing = Metrics.Spacing.horizontal
        
        addSubview(hStack)
        
        hStack.addArrangedSubviews(
            titleLabel,
            spacer,
            filterContainer
        )
        
        filterContainer.addSubviews(
            filterButton,
            filterLabel,
            badgeBackgroundView
        )
        
        badgeBackgroundView.addSubview(badgeLabel)
    }
}

// MARK: - Layout

private extension CatalogSectionHeader {
    func setupLayout() {
        prepareForAutoLayout()
        setupStackConstraints()
        setupFilterConstraints()
        setupBadgeConstraints()
        setupPriorities()
    }
    
    func prepareForAutoLayout() {
        [hStack,
         filterContainer,
         filterButton,
         filterLabel,
         badgeBackgroundView,
         badgeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            
            
        }
    }
    
    func setupStackConstraints() {
        NSLayoutConstraint.activate([
            hStack.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Metrics.Insets.horizontal
            ),
            hStack.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -Metrics.Insets.horizontal
            ),
            hStack.topAnchor.constraint(
                
                equalTo: topAnchor
                
            ),
            hStack.bottomAnchor.constraint(
                
                equalTo: bottomAnchor
                
            )
        ])
    }
    
    func setupFilterConstraints() {
        NSLayoutConstraint.activate([
            filterContainer.heightAnchor.constraint(
                greaterThanOrEqualTo: filterButton.heightAnchor
            ),
            
            filterButton.leadingAnchor.constraint(
                equalTo: filterContainer.leadingAnchor
            ),
            filterButton.centerYAnchor.constraint(
                equalTo: filterContainer.centerYAnchor
            ),
            
            filterLabel.centerYAnchor.constraint(
                equalTo: filterButton.centerYAnchor
            ),
            filterLabel.leadingAnchor.constraint(
                equalTo: filterButton.trailingAnchor,
                constant: Metrics.Button.spacingToLabel
            )
        ])
        
        labelTrailingConstraint = filterLabel.trailingAnchor.constraint(
            equalTo: filterContainer.trailingAnchor
        )
        labelTrailingConstraint?.isActive = true
    }
    
    func setupBadgeConstraints() {
        NSLayoutConstraint.activate([
            badgeBackgroundView.centerYAnchor.constraint(
                equalTo: filterLabel.centerYAnchor
            ),
            badgeBackgroundView.leadingAnchor.constraint(
                equalTo: filterLabel.trailingAnchor,
                constant: Metrics.Button.spacingToBadge
            ),
            badgeBackgroundView.heightAnchor.constraint(
                greaterThanOrEqualToConstant: Metrics.Badge.minSide
            ),
            badgeBackgroundView.widthAnchor.constraint(
                greaterThanOrEqualTo: badgeBackgroundView.heightAnchor
            ),
            
            badgeLabel.leadingAnchor.constraint(
                equalTo: badgeBackgroundView.leadingAnchor,
                constant: Metrics.Badge.contentH / 2
            ),
            badgeLabel.trailingAnchor.constraint(
                equalTo: badgeBackgroundView.trailingAnchor,
                constant: -Metrics.Badge.contentH / 2
            ),
            badgeLabel.topAnchor.constraint(
                equalTo: badgeBackgroundView.topAnchor,
                constant: Metrics.Badge.contentV
            ),
            badgeLabel.bottomAnchor.constraint(
                equalTo: badgeBackgroundView.bottomAnchor,
                constant: -Metrics.Badge.contentV
            )
        ])
        
        badgeTrailingConstraint = badgeBackgroundView.trailingAnchor.constraint(
            equalTo: filterContainer.trailingAnchor
        )
    }
    
    func setupPriorities() {
        titleLabel.setContentHuggingPriority(
            .defaultLow,
            for: .horizontal
        )
        spacer.setContentHuggingPriority(
            .defaultLow,
            for: .horizontal
        )
        filterContainer.setContentHuggingPriority(
            .required,
            for: .horizontal
        )
        filterContainer.setContentCompressionResistancePriority(
            .required,
            for: .horizontal
        )
    }
}

// MARK: - Actions

private extension CatalogSectionHeader {
    func setupActions() {
        filterButton.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        filterLabel.isUserInteractionEnabled = true
        filterLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(filterTapped))
        )
    }
    
    @objc func filterTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onFilterTap?()
    }
}

