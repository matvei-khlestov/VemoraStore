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
    
    // MARK: - UI
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.alwaysBounceVertical = true
        textView.backgroundColor = .systemBackground
        textView.textContainerInset = .init(top: 16, left: 16, bottom: 24, right: 16)
        textView.font = .systemFont(ofSize: 15)
        textView.textColor = .label
        textView.adjustsFontForContentSizeCategory = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupNavigationBarWithNavLeftItem(
            title: "Политика конфиденциальности",
            action:  #selector(backTapped),
            largeTitleDisplayMode: .never,
            prefersLargeTitles: false
        )
        
        setupLayout()
        applyContent()
    }
    
    // MARK: - UI Build
    
    private func setupLayout() {
        view.addSubview(textView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Content
    
    private func applyContent() {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 2
        paragraph.paragraphSpacing = 6
        
        let attr = NSMutableAttributedString(
            string: PrivacyPolicyText.body,
            attributes: [
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: UIColor.label,
                .paragraphStyle: paragraph
            ]
        )
        
        textView.attributedText = attr
    }
    
    // MARK: - Actions
    
    @objc private func backTapped() {
        onBack?()
    }
}
