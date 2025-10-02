//
//  AboutViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import UIKit

final class AboutViewController: UIViewController {
    
    // MARK: - Callbacks
    
    var onBack: (() -> Void)?
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 16
            static let verticalContent: CGFloat = 24
        }
        enum Spacing {
            static let verticalStack: CGFloat = 20
        }
        enum Bullets {
            static let rowSpacing: CGFloat = 12
            static let iconSize: CGFloat = 22
            static let interLabelSpacing: CGFloat = 4
        }
        enum Fonts {
            static let intro: UIFont = .preferredFont(forTextStyle: .body)
            static let bulletTitle: UIFont = .preferredFont(forTextStyle: .headline)
            static let bulletSubtitle: UIFont = .preferredFont(forTextStyle: .subheadline)
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let navigationTitle = "О нас"
    }
    
    // MARK: - Symbols
    
    private enum Symbols {
        static let bulletIcon = "checkmark.seal.fill"
    }
    
    // MARK: - UI
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceVertical = true
        view.showsVerticalScrollIndicator = true
        return view
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = Metrics.Spacing.verticalStack
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(
            top: Metrics.Insets.verticalContent,
            left: Metrics.Insets.horizontal,
            bottom: Metrics.Insets.verticalContent,
            right: Metrics.Insets.horizontal
        )
        stack.addArrangedSubviews(introLabel, bulletsStack)
        return stack
    }()
    
    private lazy var introLabel: UILabel = {
        let label = UILabel()
        label.text = AboutTexts.intro
        label.font = Metrics.Fonts.intro
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var bulletsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = Metrics.Bullets.rowSpacing
        return stack
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupNavigationBar()
        setupHierarchy()
        setupLayout()
        populateBullets()
    }
}

// MARK: - Setup

private extension AboutViewController {
    func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    func setupNavigationBar() {
        setupNavigationBarWithNavLeftItem(
            title: Texts.navigationTitle,
            action: #selector(backTapped)
        )
    }
    
    func setupHierarchy() {
        view.addSubviews(scrollView)
        scrollView.addSubview(contentStack)
    }
    
    func setupLayout() {
        prepareForAutoLayout()
        setupScrollConstraints()
        setupContentConstraints()
    }
}

// MARK: - Layout

private extension AboutViewController {
    func prepareForAutoLayout() {
        [scrollView, contentStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupScrollConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            scrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            scrollView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])
    }
    
    func setupContentConstraints() {
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor
            ),
            contentStack.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor
            ),
            contentStack.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor
            ),
            contentStack.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor
            )
        ])
    }
}

// MARK: - Data

private extension AboutViewController {
    func populateBullets() {
        bulletsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        AboutTexts.bullets.forEach { title, subtitle in
            bulletsStack.addArrangedSubview(
                Self.makeBulletRow(title: title, subtitle: subtitle)
            )
        }
    }
}

// MARK: - Actions

private extension AboutViewController {
    @objc func backTapped() { onBack?() }
}

// MARK: - Helpers

private extension AboutViewController {
    static func makeLabel(
        text: String? = nil,
        font: UIFont,
        color: UIColor,
        lines: Int,
        alignment: NSTextAlignment = .natural
    ) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.numberOfLines = lines
        label.textAlignment = alignment
        label.adjustsFontForContentSizeCategory = true
        return label
    }
    
    static func makeBulletRow(title: String, subtitle: String) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = Metrics.Bullets.rowSpacing
        
        let icon = UIImageView(image: UIImage(systemName: Symbols.bulletIcon))
        icon.tintColor = .brightPurple
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: Metrics.Bullets.iconSize),
            icon.heightAnchor.constraint(equalToConstant: Metrics.Bullets.iconSize)
        ])
        
        let labels = UIStackView()
        labels.axis = .vertical
        labels.alignment = .fill
        labels.spacing = Metrics.Bullets.interLabelSpacing
        
        let titleLabel = makeLabel(
            text: title,
            font: Metrics.Fonts.bulletTitle,
            color: .label,
            lines: 0
        )
        let subtitleLabel = makeLabel(
            text: subtitle,
            font: Metrics.Fonts.bulletSubtitle,
            color: .secondaryLabel,
            lines: 0
        )
        
        labels.addArrangedSubviews(titleLabel, subtitleLabel)
        row.addArrangedSubviews(icon, labels)
        return row
    }
}
