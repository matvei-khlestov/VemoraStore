//
//  PhoneInputSheetViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.09.2025.
//

import UIKit

final class PhoneInputSheetViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    // Ensure sheet style is set before presentation
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .pageSheet
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .pageSheet
    }

    // MARK: - Kind
    enum Kind {
        case phone
        case comment
    }

    // MARK: - Public
    var kind: Kind = .phone
    var initialPhone: String?
    var initialComment: String?
    var onSave: ((String) -> Void)?     // для phone вернёт номер; для comment — текст комментария

    // MARK: - UI
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Укажите номер получателя"
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    // phone
    private let textField: UITextField = {
        let tf = UITextField()
        tf.keyboardType = .numberPad
        tf.borderStyle = .roundedRect
        tf.placeholder = "Номер телефона"
        tf.text = "+"
        tf.clearButtonMode = .whileEditing
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return tf
    }()

    // comment
    private let textViewContainer = UIView()
    private let textView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 15)
        tv.isScrollEnabled = true
        tv.textContainerInset = .init(top: 10, left: 12, bottom: 10, right: 12)
        tv.backgroundColor = .secondarySystemBackground
        tv.layer.cornerRadius = 10
        tv.layer.borderWidth = 0 // красную обводку покажем при необходимости
        // Make height flexible to avoid constraint conflicts with small detents
        let h = tv.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        h.priority = .defaultHigh
        h.isActive = true
        tv.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return tv
    }()
    private let placeholderLabel: UILabel = {
        let l = UILabel()
        l.text = "Комментарий к заказу"
        l.font = .systemFont(ofSize: 15)
        l.textColor = .secondaryLabel
        return l
    }()

    private let saveButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Сохранить", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        b.backgroundColor = .brightPurple
        b.tintColor = .white
        b.layer.cornerRadius = 12
        b.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return b
    }()

    private let stack = UIStackView()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .secondaryLabel
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSheet()
        setupLayout()
        configureForKind()

        textField.delegate = self
        textView.delegate = self
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }

    // MARK: - Layout / Sheet
    private func setupLayout() {
        // контейнер для textView + placeholder
        textViewContainer.backgroundColor = .clear
        textViewContainer.layer.cornerRadius = 10
        textViewContainer.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

        textViewContainer.addSubview(textView)
        textViewContainer.addSubview(placeholderLabel)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: textViewContainer.topAnchor),
            textView.leadingAnchor.constraint(equalTo: textViewContainer.leadingAnchor, constant: 0),
            textView.trailingAnchor.constraint(equalTo: textViewContainer.trailingAnchor, constant: 0),
            textView.bottomAnchor.constraint(equalTo: textViewContainer.bottomAnchor),

            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 10),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: textView.trailingAnchor, constant: -12)
        ])

        stack.axis = .vertical
        stack.spacing = 15
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(top: 16, left: 16, bottom: 24, right: 16)

        // по умолчанию добавим всё; нужное будем скрывать/показывать
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(textField)
        stack.addArrangedSubview(textViewContainer)
        stack.addArrangedSubview(saveButton)

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])

        // кнопка закрытия
        view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            closeButton.widthAnchor.constraint(equalToConstant: 20),
            closeButton.heightAnchor.constraint(equalToConstant: 20)
        ])
        view.bringSubviewToFront(closeButton)
    }

    private func setupSheet() {
        if let sheet = presentationController as? UISheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [
                    .custom { _ in 300 },
                ]
                sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            } else {
                sheet.detents = [.medium(), .large()]
            }
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
            sheet.largestUndimmedDetentIdentifier = nil
        }
    }

    // MARK: - Kind switch
    private func configureForKind() {
        switch kind {
        case .phone:
            titleLabel.text = "Укажите номер получателя"
            textField.isHidden = false
            textViewContainer.isHidden = true

            if let initial = initialPhone, !initial.isEmpty {
                textField.text = initial
            } else {
                textField.text = "+"
            }
            updateValidationUI()

        case .comment:
            titleLabel.text = "Комментарий"
            titleLabel.textAlignment = .left
            textField.isHidden = true
            textViewContainer.isHidden = false

            textView.text = initialComment ?? ""
            placeholderLabel.isHidden = !(textView.text?.isEmpty ?? true)
            
            textView.layer.borderWidth = 0
            textView.layer.borderColor = UIColor.clear.cgColor
            
            if let text = textView.text, !text.isEmpty {
                textView.layer.borderWidth = 1
                textView.layer.borderColor = UIColor.brightPurple.cgColor
            }
        }
    }

    // MARK: - Validation (phone)
    
    private func isValidPhone(_ s: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: #"^\+7\d{10}$"#)
        return regex.firstMatch(in: s, range: NSRange(location: 0, length: s.utf16.count)) != nil
    }

    private func updateValidationUI() {
        guard kind == .phone else { return }
        let valid = isValidPhone(textField.text ?? "")
        // Красная обводка при невалидном
        textField.layer.borderWidth = 1
        textField.layer.borderColor = valid ? UIColor.brightPurple.cgColor : UIColor.systemRed.cgColor
        textField.layer.cornerRadius = 8
    }

    // MARK: - Actions
    @objc private func saveTapped() {
        switch kind {
        case .phone:
            let value = textField.text ?? ""
            if isValidPhone(value) {
                onSave?(value)
                dismiss(animated: true)
            } else {
                updateValidationUI()
                let anim = CABasicAnimation(keyPath: "position")
                anim.duration = 0.05
                anim.repeatCount = 3
                anim.autoreverses = true
                anim.fromValue = NSValue(cgPoint: CGPoint(x: textField.center.x - 6, y: textField.center.y))
                anim.toValue   = NSValue(cgPoint: CGPoint(x: textField.center.x + 6, y: textField.center.y))
                textField.layer.add(anim, forKey: "shake")
            }

        case .comment:
            let value = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if value.isEmpty {
                textView.layer.borderWidth = 1
                textView.layer.borderColor = UIColor.systemRed.cgColor
                let anim = CABasicAnimation(keyPath: "position")
                anim.duration = 0.05
                anim.repeatCount = 3
                anim.autoreverses = true
                anim.fromValue = NSValue(cgPoint: CGPoint(x: textView.center.x - 6, y: textView.center.y))
                anim.toValue   = NSValue(cgPoint: CGPoint(x: textView.center.x + 6, y: textView.center.y))
                textView.layer.add(anim, forKey: "shake")
                return
            }
            
            textView.layer.borderWidth = 1
            textView.layer.borderColor = UIColor.brightPurple.cgColor
            onSave?(value)
            dismiss(animated: true)
        }
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    // MARK: - UITextFieldDelegate (phone)
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard kind == .phone else { return true }

        let current = textField.text ?? "+"
        guard let r = Range(range, in: current) else { return false }
        var next = current.replacingCharacters(in: r, with: string)

        if next.isEmpty { next = "+" }
        if next.first != "+" { return false }
        let afterPlus = next.dropFirst()
        if afterPlus.contains(where: { !$0.isNumber }) { return false }
        if afterPlus.count > 11 { return false }
        if let firstDigit = afterPlus.first, firstDigit != "7" { return false }

        textField.text = next
        updateValidationUI()
        return false
    }

    // MARK: - UITextViewDelegate (comment)
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        if !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.layer.borderWidth = 1
            textView.layer.borderColor = UIColor.brightPurple.cgColor
        } else {
            textView.layer.borderWidth = 1
            textView.layer.borderColor = UIColor.systemRed.cgColor
        }
    }
}
