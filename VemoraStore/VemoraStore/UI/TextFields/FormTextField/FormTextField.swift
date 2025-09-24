//
//  FormTextField.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 19.09.2025.
//

import UIKit

final class FormTextField: UIView {
    
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
    
    private let kind: FormTextFieldKind
    private var isSecure = false
    // Показывать ошибки только после первого взаимодействия,
    // либо по явному форсу при сабмите формы
    private var hasInteracted = false
    private var pendingError: String? = nil
    private var errorLabelHeight: NSLayoutConstraint?
    
    init(kind: FormTextFieldKind) {
        self.kind = kind
        super.init(frame: .zero)
        build()
        applyKind(kind)
        textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        textField.delegate = self
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
    
    private func applyKind(_ kind: FormTextFieldKind) {
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
        case .phone:
            textField.autocapitalizationType = .none
            textField.textContentType = .telephoneNumber
            textField.keyboardType = .numberPad
            textField.returnKeyType = .done
            // дефолтное значение
            textField.text = "+7"
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
            textField.layer.borderWidth = 0.5
            textField.layer.borderColor = UIColor.secondarySystemFill.cgColor
        }
    }
    
    @objc private func editingChanged() {
        if !hasInteracted {
            hasInteracted = true
            updateErrorVisibility(force: false)
        }
        // для телефона onTextChanged вызываем из delegate с нормализацией
        if kind != .phone {
            onTextChanged?(text)
        }
    }
    
    @objc private func toggleSecure() {
        isSecure.toggle()
        textField.isSecureTextEntry = isSecure
        let img = UIImage(systemName: isSecure ? "eye" : "eye.slash")
        eyeButton.setImage(img, for: .normal)
    }

    // MARK: - Phone formatting helpers

    /// Оставляем только цифры
    private func digits(from string: String) -> String {
        string.filter(\.isNumber)
    }

    /// Принимает текущий raw + новые изменения, возвращает:
    /// - display: формат для показа "+7 (XXX) XXX-XX-XX"
    /// - e164:     нормализованный "+7XXXXXXXXXX" (для хранения/валидации)
    private func formatRussianPhone(displaying rawDigits: String) -> (display: String, e164: String) {
        // гарантируем, что начинается на 7
        var digitsOnly = rawDigits
        if digitsOnly.first != "7" {
            // удаляем ведущие 8, 9 и т.п., подставляем 7
            digitsOnly = "7" + digitsOnly.drop(while: { $0 == "7" })
        }
        // ограничим максимум 11 цифр (включая первую 7)
        digitsOnly = String(digitsOnly.prefix(11))

        // e164: "+7XXXXXXXXXX" — 11 цифр, где первая '7'
        let e164 = "+" + digitsOnly

        // строим отображение: +7 (XXX) XXX-XX-XX
        let tail = String(digitsOnly.dropFirst()) // 10 цифр после 7
        let a = String(tail.prefix(3))
        let b = String(tail.dropFirst(3).prefix(3))
        let c = String(tail.dropFirst(6).prefix(2))
        let d = String(tail.dropFirst(8).prefix(2))

        var display = "+7"
        if !a.isEmpty { display += " (\(a)" + (a.count == 3 ? ")" : "") }
        if !b.isEmpty { display += a.isEmpty ? " (\(b)" : " \(b)" }
        if !c.isEmpty { display += "-\(c)" }
        if !d.isEmpty { display += "-\(d)" }

        return (display, e164)
    }
}

extension FormTextField: UITextFieldDelegate {
    public func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard kind == .phone else { return true }

        let current = textField.text ?? "+7"
        if let textRange = Range(range, in: current) {
            let newText = current.replacingCharacters(in: textRange, with: string)

            var digitsOnly = digits(from: newText)
            if digitsOnly.isEmpty { digitsOnly = "7" }

            let (display, e164) = formatRussianPhone(displaying: digitsOnly)
            textField.text = display

            // сообщаем наружу уже нормализованный вид: +7XXXXXXXXXX
            onTextChanged?(e164)

            // каретку в конец
            if let endPos = textField.endOfDocument as UITextPosition? {
                textField.selectedTextRange = textField.textRange(from: endPos, to: endPos)
            }
        }
        return false // мы сами выставили text
    }

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if kind == .phone, (textField.text ?? "").isEmpty {
            textField.text = "+7"
        }
        return true
    }
}
