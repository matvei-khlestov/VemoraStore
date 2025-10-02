//
//  FormTextField.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 19.09.2025.
//

import UIKit

final class FormTextField: UIView {
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Spacing {
            static let vertical: CGFloat = 6
        }
        enum Corners {
            static let textField: CGFloat = 10
        }
        enum Sizes {
            static let textFieldHeight: CGFloat = 48
            static let eyeWidth: CGFloat = 30
            static let eyeHeight: CGFloat = 24
            static let rightViewWidth: CGFloat = 44
            static let errorHeight: CGFloat = 16
            static let borderErrorWidth: CGFloat = 1.0
            static let borderNormalWidth: CGFloat = 0.5
        }
        enum Insets {
            static let textFieldLeft: CGFloat = 12
            static let eyeTrailing: CGFloat = 12
        }
        enum Fonts {
            static let title: UIFont = .systemFont(ofSize: 16, weight: .semibold)
            static let error: UIFont = .systemFont(ofSize: 13, weight: .regular)
        }
        enum Colors {
            static let error: UIColor = .systemRed
            static let borderError: CGColor = UIColor.systemRed.withAlphaComponent(0.6).cgColor
            static let borderNormal: CGColor = UIColor.secondarySystemFill.cgColor
        }
    }
    
    // MARK: - Symbols
    
    private enum Symbols {
        static let eye = "eye"
        static let eyeSlash = "eye.slash"
    }
    
    // MARK: - Public API
    
    var onTextChanged: ((String) -> Void)?
    
    var text: String {
        get { textField.text ?? "" }
        set {
            switch kind {
            case .phone:
                if let phoneFormatter {
                    textField.text = phoneFormatter.displayForTextField(newValue)
                } else {
                    textField.text = newValue
                }
            default:
                textField.text = newValue
            }
        }
    }
    
    // MARK: - State
    
    private let kind: FormTextFieldKind
    private let phoneFormatter: PhoneFormattingProtocol?
    private var isSecure = false
    private var hasInteracted = false
    private var pendingError: String?
    private var errorLabelHeight: NSLayoutConstraint?
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = Metrics.Fonts.title
        return l
    }()
    
    let textField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = .secondarySystemBackground
        tf.layer.cornerRadius = Metrics.Corners.textField
        tf.layer.masksToBounds = true
        tf.clearButtonMode = .whileEditing
        tf.heightAnchor.constraint(
            equalToConstant: Metrics.Sizes.textFieldHeight
        ).isActive = true
        
        // левый паддинг
        let left = UIView(
            frame: .init(
                x: 0,
                y: 0,
                width: Metrics.Insets.textFieldLeft,
                height: Metrics.Sizes.textFieldHeight
            )
        )
        tf.leftView = left
        tf.leftViewMode = .always
        return tf
    }()
    
    private let eyeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: Symbols.eyeSlash), for: .normal)
        b.tintColor = .secondaryLabel
        return b
    }()
    
    private let errorLabel: UILabel = {
        let l = UILabel()
        l.textColor = Metrics.Colors.error
        l.font = Metrics.Fonts.error
        l.numberOfLines = 1
        l.lineBreakMode = .byTruncatingTail
        l.alpha = 0
        return l
    }()
    
    private let vStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.alignment = .fill
        v.spacing = Metrics.Spacing.vertical
        return v
    }()
    
    private let eyeContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    // MARK: - Init
    
    init(
        kind: FormTextFieldKind,
        phoneFormatter: PhoneFormattingProtocol? = nil
    ) {
        self.kind = kind
        self.phoneFormatter = phoneFormatter
        super.init(frame: .zero)
        setupHierarchy()
        setupLayout()
        applyKind(kind)
        wire()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension FormTextField {
    func setupHierarchy() {
        vStack.addArrangedSubviews(
            titleLabel,
            textField,
            errorLabel
        )
        
        addSubview(vStack)
        eyeContainer.addSubview(eyeButton)
    }
    
    func setupLayout() {
        [vStack, errorLabel, eyeContainer, eyeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupVStackConstraints()
        setupEyeConstraints()
        setupErrorLabelConstraints()
    }
    
    func wire() {
        textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        textField.delegate = self
        eyeButton.addTarget(self, action: #selector(toggleSecure), for: .touchUpInside)
    }
}

// MARK: - Layout

private extension FormTextField {
    private func setupVStackConstraints() {
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: topAnchor),
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupEyeConstraints() {
        NSLayoutConstraint.activate([
            eyeButton.widthAnchor.constraint(
                equalToConstant: Metrics.Sizes.eyeWidth
            ),
            eyeButton.heightAnchor.constraint(
                equalToConstant: Metrics.Sizes.eyeHeight
            ),
            eyeButton.centerYAnchor.constraint(
                equalTo: eyeContainer.centerYAnchor
            ),
            eyeButton.trailingAnchor.constraint(
                equalTo: eyeContainer.trailingAnchor,
                constant: -Metrics.Insets.eyeTrailing
            ),
            
            eyeContainer.widthAnchor.constraint(
                equalToConstant: Metrics.Sizes.rightViewWidth
            ),
            eyeContainer.heightAnchor.constraint(
                equalToConstant: Metrics.Sizes.textFieldHeight
            )
        ])
    }
    
    private func setupErrorLabelConstraints() {
        let c = errorLabel.heightAnchor.constraint(
            equalToConstant: Metrics.Sizes.errorHeight
        )
        c.isActive = true
        errorLabelHeight = c
    }
}

// MARK: - Kind / Behavior

private extension FormTextField {
    func applyKind(_ kind: FormTextFieldKind) {
        titleLabel.text = kind.title
        textField.placeholder = kind.placeholder
        
        switch kind {
        case .name:
            textField.autocapitalizationType = .words
            textField.textContentType = .name
            textField.keyboardType = .default
            textField.returnKeyType = .next
            
        case .email:
            textField.autocapitalizationType = .none
            textField.textContentType = .emailAddress
            textField.keyboardType = .emailAddress
            textField.autocorrectionType = .no
            textField.smartDashesType = .no
            textField.smartQuotesType = .no
            textField.smartInsertDeleteType = .no
            textField.returnKeyType = .next
            
        case .password:
            textField.autocapitalizationType = .none
            textField.textContentType = .oneTimeCode
            textField.passwordRules = nil
            textField.keyboardType = .asciiCapable
            textField.autocorrectionType = .no
            textField.smartDashesType = .no
            textField.smartQuotesType = .no
            textField.smartInsertDeleteType = .no
            textField.returnKeyType = .done
            
            isSecure = true
            textField.isSecureTextEntry = true
            textField.rightView = eyeContainer
            textField.rightViewMode = .always
            updateEyeIcon()
            
        case .phone:
            textField.autocapitalizationType = .none
            textField.textContentType = .telephoneNumber
            textField.keyboardType = .numberPad
            textField.returnKeyType = .done
            textField.text = phoneFormatter?.displayForTextField(nil) ?? "+7"
        }
    }
}

// MARK: - Public API

extension FormTextField {
    func setPhoneE164(_ e164: String?) {
        if let phoneFormatter {
            textField.text = phoneFormatter.displayForTextField(e164)
        } else {
            textField.text = e164 ?? ""
        }
    }
}

// MARK: - Error API

extension FormTextField {
    func showError(_ message: String?, force: Bool = false) {
        pendingError = message
        updateErrorVisibility(force: force)
    }
}

// MARK: - Error rendering

private extension FormTextField {
    func updateErrorVisibility(force: Bool) {
        let shouldShow = force
        ? (pendingError?.isEmpty == false)
        : (hasInteracted && (pendingError?.isEmpty == false))
        
        if shouldShow {
            errorLabel.text = pendingError
            errorLabel.alpha = 1
            textField.layer.borderWidth = Metrics.Sizes.borderErrorWidth
            textField.layer.borderColor = Metrics.Colors.borderError
        } else {
            errorLabel.text = ""
            errorLabel.alpha = 0
            textField.layer.borderWidth = Metrics.Sizes.borderNormalWidth
            textField.layer.borderColor = Metrics.Colors.borderNormal
        }
    }
}

// MARK: - Actions

private extension FormTextField {
    @objc func editingChanged() {
        if !hasInteracted {
            hasInteracted = true
            updateErrorVisibility(force: false)
        }
        // для телефона onTextChanged вызывается из делегата (с нормализацией)
        if kind != .phone {
            onTextChanged?(text)
        }
    }
    
    @objc func toggleSecure() {
        isSecure.toggle()
        textField.isSecureTextEntry = isSecure
        updateEyeIcon()
    }
    
    func updateEyeIcon() {
        let name = isSecure ? Symbols.eyeSlash : Symbols.eye
        eyeButton.setImage(UIImage(systemName: name), for: .normal)
    }
}



// MARK: - UITextFieldDelegate

extension FormTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard kind == .phone, let phoneFormatter else { return true }
        let current = textField.text ?? "+7"
        guard let textRange = Range(range, in: current) else { return false }
        
        let digits = normalizedDigits(
            current: current,
            range: textRange,
            replacement: string,
            using: phoneFormatter
        )
        
        applyPhoneFormat(digits, to: textField, using: phoneFormatter)
        return false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        hasInteracted = true
        
        switch kind {
        case .phone:
            textField.text = phoneFormatter?.displayForTextField(nil) ?? "+7"
            if let end = textField.endOfDocument as UITextPosition? {
                textField.selectedTextRange = textField.textRange(from: end, to: end)
            }
            onTextChanged?("")
            updateErrorVisibility(force: false)
            return false
            
        default:
            onTextChanged?("")
            updateErrorVisibility(force: false)
            return true
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if kind == .phone, (textField.text ?? "").isEmpty {
            textField.text = phoneFormatter?.displayForTextField(nil) ?? "+7"
        }
        return true
    }
}

// MARK: - Phone Formatting Helpers

private extension FormTextField {
    /// Возвращает нормализованные цифры после редактирования.
    func normalizedDigits(current: String,
                          range: Range<String.Index>,
                          replacement: String,
                          using formatter: PhoneFormattingProtocol) -> String {
        let isBackspace = replacement.isEmpty
        let deletedSubstring = current[range]
        
        var newDigits: String
        if isBackspace {
            if deletedSubstring.contains(where: \.isNumber) {
                let afterDeletion = current.replacingCharacters(in: range, with: "")
                newDigits = formatter.digits(from: afterDeletion)
            } else {
                var d = formatter.digits(from: current)
                if !d.isEmpty { _ = d.removeLast() }
                newDigits = d
            }
        } else {
            let replaced = current.replacingCharacters(in: range, with: replacement)
            newDigits = formatter.digits(from: replaced)
        }
        
        if newDigits.isEmpty { newDigits = "7" }
        return newDigits
    }
    
    /// Применяет маску, обновляет текст и курсор, дергает onTextChanged.
    func applyPhoneFormat(_ digits: String,
                          to textField: UITextField,
                          using formatter: PhoneFormattingProtocol) {
        let formatted = formatter.formatRussianPhone(digits)
        textField.text = formatted.display
        onTextChanged?(formatted.e164)
        if let end = textField.endOfDocument as UITextPosition? {
            textField.selectedTextRange = textField.textRange(from: end, to: end)
        }
    }
}
