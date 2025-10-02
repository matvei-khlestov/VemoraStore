//
//  LabelLinkRow.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 22.09.2025.
//

import UIKit

/// Ряд: текст + подчёркнутая кнопка (по умолчанию по центру).
/// Использует UnderlinedButton.
final class LabelLinkRow: UIView {
    
    // MARK: - Public
    
    /// Колбэк на нажатие кнопки
    var onTap: (() -> Void)?
    
    /// Доступ к кнопке снаружи (например, для подписки на события)
    var button: UIButton {
        linkButton
    }
    
    // MARK: - State
    
    private let initialAlignment: NSTextAlignment
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Spacing {
            static let hSpacing: CGFloat = 6
        }
    }
    
    // MARK: - UI
    
    private let labelView: UILabel = {
        let l = UILabel()
        l.textColor = .secondaryLabel
        l.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        l.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return l
    }()
    
    private let linkButton: UnderlinedButton = {
        let b = UnderlinedButton(text: "Action")
        b.setContentHuggingPriority(.required, for: .horizontal)
        b.setContentCompressionResistancePriority(.required, for: .horizontal)
        return b
    }()
    
    private let stack: UIStackView = {
        let v = UIStackView()
        v.axis = .horizontal
        v.alignment = .center
        v.spacing = Metrics.Spacing.hSpacing
        return v
    }()
    
    // MARK: - Init
    
    init(
        label: String,
        button: String,
        alignment: NSTextAlignment = .center
    ) {
        self.initialAlignment = alignment
        super.init(frame: .zero)
        labelView.text = label
        linkButton.setText(button)
        setup()
    }
    
    required init?(coder: NSCoder) {
        self.initialAlignment = .center
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - API
    
    /// Изменить тексты на лету
    func configure(label: String, button: String) {
        labelView.text = label
        linkButton.setText(button)
    }
}

// MARK: - Setup

private extension LabelLinkRow {
    func setup() {
        setupAppearance()
        setupHierarchy()
        setupLayout()
        setupActions()
    }
    
    func setupAppearance() {
        labelView.textAlignment = initialAlignment
    }
    
    func setupHierarchy() {
        addSubview(stack)
        stack.addArrangedSubviews(
            labelView,
            linkButton
        )
    }
    
    func setupLayout() {
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setupActions() {
        linkButton.onTap(self, action: #selector(tap))
    }
}

// MARK: - Actions

private extension LabelLinkRow {
    @objc func tap() {
        onTap?()
    }
}
