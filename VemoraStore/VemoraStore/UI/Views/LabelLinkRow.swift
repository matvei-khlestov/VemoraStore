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
    
    /// Изменить тексты на лету
    func configure(label: String, button: String) {
        labelView.text = label
        linkButton.setText(button)
    }
    
    /// Доступ к кнопке, если нужно подписаться извне
    var button: UIButton { linkButton }
    
    // MARK: - UI
    
    private let labelView: UILabel = {
        let l = UILabel()
        l.textColor = .secondaryLabel
        l.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        l.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return l
    }()
    
    private let linkButton: UnderlinedButton = {
        let b = UnderlinedButton(text: "Action") // будет переопределён в init
        b.setContentHuggingPriority(.required, for: .horizontal)
        b.setContentCompressionResistancePriority(.required, for: .horizontal)
        return b
    }()
    
    private let stack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 6
        return sv
    }()
    
    // MARK: - Init
    
    init(label: String, button: String, alignment: NSTextAlignment = .center) {
        super.init(frame: .zero)
        labelView.text = label
        linkButton.setText(button)
        setup(alignment: alignment)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup(alignment: .center)
    }
    
    // MARK: - Private
    
    private func setup(alignment: NSTextAlignment) {
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.addArrangedSubview(labelView)
        stack.addArrangedSubview(linkButton)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Клик
        linkButton.addTarget(self, action: #selector(tap), for: .touchUpInside)
    }
    
    @objc private func tap() { onTap?() }
}
