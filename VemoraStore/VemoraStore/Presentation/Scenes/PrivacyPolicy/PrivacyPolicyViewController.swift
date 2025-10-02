//
//  PrivacyPolicyViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 17.09.2025.
//

import UIKit

final class PrivacyPolicyViewController: UIViewController {
    
    // MARK: - Callbacks
    
    var onBack: (() -> Void)?
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 16
            static let verticalTop: CGFloat = 16
            static let verticalBottom: CGFloat = 24
        }
        enum Fonts {
            static let body: UIFont = .systemFont(ofSize: 15, weight: .regular)
        }
        enum Paragraph {
            static let lineSpacing: CGFloat = 2
            static let paragraphSpacing: CGFloat = 6
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let navigationTitle = "Политика конфиденциальности"
    }
    
    // MARK: - UI
    
    private lazy var textView: UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.isSelectable = true
        view.alwaysBounceVertical = true
        view.backgroundColor = .systemBackground
        view.textContainerInset = .init(
            top: Metrics.Insets.verticalTop,
            left: Metrics.Insets.horizontal,
            bottom: Metrics.Insets.verticalBottom,
            right: Metrics.Insets.horizontal
        )
        view.adjustsFontForContentSizeCategory = true
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupNavigationBar()
        setupHierarchy()
        setupLayout()
        applyContent()
    }
}

// MARK: - Setup

private extension PrivacyPolicyViewController {
    func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    func setupNavigationBar() {
        setupNavigationBarWithNavLeftItem(
            title: Texts.navigationTitle,
            action: #selector(backTapped),
            largeTitleDisplayMode: .never,
            prefersLargeTitles: false
        )
    }
    
    func setupHierarchy() {
        view.addSubviews(textView)
    }
    
    func setupLayout() {
        prepareForAutoLayout()
        setupConstraints()
    }
}

// MARK: - Layout

private extension PrivacyPolicyViewController {
    func prepareForAutoLayout() {
        [textView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            textView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            textView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            textView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])
    }
}

// MARK: - Content

private extension PrivacyPolicyViewController {
    func applyContent() {
        textView.attributedText = makeAttributedPolicyText(PrivacyPolicyText.body)
    }
    
    func makeAttributedPolicyText(_ text: String) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = Metrics.Paragraph.lineSpacing
        paragraph.paragraphSpacing = Metrics.Paragraph.paragraphSpacing
        
        return NSAttributedString(
            string: text,
            attributes: [
                .font: Metrics.Fonts.body,
                .foregroundColor: UIColor.label,
                .paragraphStyle: paragraph
            ]
        )
    }
}

// MARK: - Actions

private extension PrivacyPolicyViewController {
    @objc func backTapped() {
        onBack?()
    }
}
