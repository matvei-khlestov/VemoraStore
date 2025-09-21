//
//  FormTextField.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 19.09.2025.
//

import UIKit

final class FormTextField: UIView {
    
    enum Kind {
        case name, email, password
        
        var title: String {
            switch self {
            case .name:     return "Имя"
            case .email:    return "E-mail"
            case .password: return "Пароль"
            }
        }
        var placeholder: String {
            switch self {
            case .name:     return "Введите имя"
            case .email:    return "Введите e-mail"
            case .password: return "Введите пароль"
            }
        }
    }
    
    // MARK: UI
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        return l
    }()
    
    let textField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .secondarySystemBackground
        tf.layer.cornerRadius = 10
        tf.layer.masksToBounds = true
        tf.leftView = UIView(frame: .init(x: 0, y: 0, width: 12, height: 44))
        tf.leftViewMode = .always
        tf.clearButtonMode = .whileEditing
        tf.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return tf
    }()
    
    private let eyeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "eye"), for: .normal)
        b.tintColor = .secondaryLabel
        return b
    }()
    
    private let errorLabel: UILabel = {
        let l = UILabel()
        l.textColor = .systemRed
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.numberOfLines = 1
        l.lineBreakMode = .byTruncatingTail
        l.alpha = 0
        return l
    }()
    
    // MARK: API
    var onTextChanged: ((String) -> Void)?
    
    private let kind: Kind
    private var isSecure = false
    // Показывать ошибки только после первого взаимодействия,
    // либо по явному форсу при сабмите формы
    private var hasInteracted = false
    private var pendingError: String? = nil
    private var errorLabelHeight: NSLayoutConstraint?
    
    init(kind: Kind) {
        self.kind = kind
        super.init(frame: .zero)
        build()
        applyKind(kind)
        textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        eyeButton.addTarget(self, action: #selector(toggleSecure), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    var text: String { textField.text ?? "" }
    
    /// Обновляет текст ошибки. По умолчанию НЕ показывает её до первого взаимодействия.
    /// Передай `force: true`, если нужно показать сразу (например, при сабмите формы).
    func showError(_ message: String?, force: Bool = false) {
        pendingError = message
        updateErrorVisibility(force: force)
    }
    
    // MARK: Private
    private func build() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, textField, errorLabel])
        stack.axis = .vertical
        stack.spacing = 6
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        // Add fixed height constraint for errorLabel
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        let c = errorLabel.heightAnchor.constraint(equalToConstant: 16)
        c.isActive = true
        self.errorLabelHeight = c
    }
    
    private func applyKind(_ kind: Kind) {
        titleLabel.text = kind.title
        textField.placeholder = kind.placeholder
        
        switch kind {
        case .name:
            textField.autocapitalizationType = .words
            textField.textContentType = .name
            textField.keyboardType = .default
            
        case .email:
            textField.autocapitalizationType = .none
            textField.textContentType = .emailAddress
            textField.keyboardType = .emailAddress
            textField.autocorrectionType = .no
            textField.smartDashesType = .no
            textField.smartQuotesType = .no
            textField.smartInsertDeleteType = .no
            
        case .password:
            textField.autocapitalizationType = .none
            textField.textContentType = .oneTimeCode
            textField.passwordRules = nil
            textField.keyboardType = .asciiCapable
            textField.autocorrectionType = .no
            textField.smartDashesType = .no
            textField.smartQuotesType = .no
            textField.smartInsertDeleteType = .no
           
            isSecure = true
            textField.isSecureTextEntry = true
            
            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(eyeButton)
            eyeButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                // eye size
                eyeButton.widthAnchor.constraint(equalToConstant: 30),
                eyeButton.heightAnchor.constraint(equalToConstant: 24),
                // eye position
                eyeButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                eyeButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),

                // container fixed size to match the text field height (48) and leave some right padding
                container.widthAnchor.constraint(equalToConstant: 44),
                container.heightAnchor.constraint(equalToConstant: 48)
            ])
            
            textField.rightView = container
            textField.rightViewMode = .always
        }
    }
    
    private func updateErrorVisibility(force: Bool) {
        let shouldShow: Bool
        if force {
            shouldShow = (pendingError?.isEmpty == false)
        } else {
            shouldShow = hasInteracted && (pendingError?.isEmpty == false)
        }
        if shouldShow {
            errorLabel.text = pendingError
            errorLabel.alpha = 1
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.6).cgColor
        } else {
            errorLabel.text = ""
            errorLabel.alpha = 0
            textField.layer.borderWidth = 0
            textField.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    @objc private func editingChanged() {
        // Показывать ошибки только после первого ввода пользователем
        if !hasInteracted {
            hasInteracted = true
            updateErrorVisibility(force: false)
        }
        onTextChanged?(text)
    }
    
    @objc private func toggleSecure() {
        isSecure.toggle()
        textField.isSecureTextEntry = isSecure
        let img = UIImage(systemName: isSecure ? "eye" : "eye.slash")
        eyeButton.setImage(img, for: .normal)
    }
}
