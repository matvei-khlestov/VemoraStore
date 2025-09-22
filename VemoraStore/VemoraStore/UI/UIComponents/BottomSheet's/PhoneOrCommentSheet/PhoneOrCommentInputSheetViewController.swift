//
//  PhoneOrCommentInputSheetViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.09.2025.
//

import UIKit
import Combine

final class PhoneOrCommentInputSheetViewController: UIViewController {
    
    // MARK: - ViewModel
    private let viewModel: PhoneOrCommentInputSheetViewModelProtocol
    
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Public API (сохраняем)
    var onSave: ((String) -> Void)?
    
    // MARK: - Init
    
    init(viewModel: PhoneOrCommentInputSheetViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }
    
    required init?(coder: NSCoder) {
        fatalError("Use init(viewModel:) to inject a view model instead of storyboard init.")
    }
    
    // MARK: - UI
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Укажите номер получателя"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .numberPad
        textField.borderStyle = .roundedRect
        textField.placeholder = "Номер телефона"
        textField.text = "+7"
        textField.clearButtonMode = .whileEditing
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return textField
    }()
    
    private let textViewContainer = UIView()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 15)
        textView.isScrollEnabled = true
        textView.textContainerInset = .init(top: 10, left: 12, bottom: 10, right: 12)
        textView.backgroundColor = .secondarySystemBackground
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth = 0
        let minH = textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        minH.priority = .defaultHigh
        minH.isActive = true
        textView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return textView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Комментарий к заказу"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let saveButton = BrandedButton(style: .primary, title: "Сохранить")
    
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
        bindViewModel()
        applyKindUI(viewModel.kind)
        
        textField.delegate = self
        textView.delegate = self
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }
    
    // MARK: - Layout / Sheet
    private func setupLayout() {
        // textView + placeholder
        textViewContainer.backgroundColor = .clear
        textViewContainer.layer.cornerRadius = 10
        textViewContainer.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        textViewContainer.addSubview(textView)
        textViewContainer.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: textViewContainer.topAnchor),
            textView.leadingAnchor.constraint(equalTo: textViewContainer.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: textViewContainer.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: textViewContainer.bottomAnchor),
            
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 10),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: textView.trailingAnchor, constant: -12)
        ])
        
        // stack
        stack.axis = .vertical
        stack.spacing = 15
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(top: 16, left: 16, bottom: 24, right: 16)
        
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
        
        // close
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
                sheet.detents = [.custom { _ in 300 }]
                sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            } else {
                sheet.detents = [.medium(), .large()]
            }
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
            sheet.largestUndimmedDetentIdentifier = nil
        }
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        // kind → UI
        viewModel.kindPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] kind in self?.applyKindUI(kind) }
            .store(in: &bag)
        
        // state ↔ controls (начальные значения)
        textField.text = viewModel.phone
        textView.text = viewModel.comment
        placeholderLabel.isHidden = !viewModel.comment.isEmpty
        
        // при изменении валидности — освежаем обводку
        viewModel.phonePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateValidationUI() }
            .store(in: &bag)
    }
    
    private func applyKindUI(_ kind: PhoneOrCommentInputSheetViewModel.Kind) {
        switch kind {
        case .phone:
            titleLabel.text = "Укажите номер получателя"
            titleLabel.textAlignment = .center
            textField.isHidden = false
            textViewContainer.isHidden = true
            updateValidationUI()
        case .comment:
            titleLabel.text = "Комментарий"
            titleLabel.textAlignment = .left
            textField.isHidden = true
            textViewContainer.isHidden = false
            placeholderLabel.isHidden = !viewModel.comment.isEmpty
            textView.layer.borderWidth = 1
            textView.layer.borderColor = viewModel.comment.isEmpty ? UIColor.clear.cgColor : UIColor.brightPurple.cgColor
        }
    }
    
    // MARK: - Validation (phone)
    
    private func updateValidationUI() {
        guard viewModel.kind == .phone else { return }
        let valid = viewModel.isPhoneValid
        textField.layer.borderWidth = 1
        textField.layer.borderColor = valid ? UIColor.brightPurple.cgColor : UIColor.systemRed.cgColor
        textField.layer.cornerRadius = 8
    }
    
    // MARK: - Actions
    
    @objc private func saveTapped() {
        if let result = viewModel.makeResultIfValid() {
            onSave?(result)
            dismiss(animated: true)
            return
        }
        
        // визуальная обратная связь при ошибке
        switch viewModel.kind {
        case .phone:
            updateValidationUI()
            let anim = CABasicAnimation(keyPath: "position")
            anim.duration = 0.05
            anim.repeatCount = 3
            anim.autoreverses = true
            anim.fromValue = NSValue(cgPoint: CGPoint(x: textField.center.x - 6, y: textField.center.y))
            anim.toValue   = NSValue(cgPoint: CGPoint(x: textField.center.x + 6, y: textField.center.y))
            textField.layer.add(anim, forKey: "shake")
        case .comment:
            textView.layer.borderWidth = 1
            textView.layer.borderColor = UIColor.systemRed.cgColor
            let anim = CABasicAnimation(keyPath: "position")
            anim.duration = 0.05
            anim.repeatCount = 3
            anim.autoreverses = true
            anim.fromValue = NSValue(cgPoint: CGPoint(x: textView.center.x - 6, y: textView.center.y))
            anim.toValue   = NSValue(cgPoint: CGPoint(x: textView.center.x + 6, y: textView.center.y))
            textView.layer.add(anim, forKey: "shake")
        }
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate (phone)

extension PhoneOrCommentInputSheetViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard viewModel.kind == .phone else { return true }
        
        let current = viewModel.phone
        guard let r = Range(range, in: current) else { return false }
        var next = current.replacingCharacters(in: r, with: string)
        
        if next.isEmpty { next = "+" }
        if next.first != "+" { return false }
        let afterPlus = next.dropFirst()
        if afterPlus.contains(where: { !$0.isNumber }) { return false }
        if afterPlus.count > 11 { return false }
        if let firstDigit = afterPlus.first, firstDigit != "7" { return false }
        
        viewModel.phone = String(next)
        textField.text = viewModel.phone
        return false
    }
}

// MARK: - UITextViewDelegate (comment)

extension PhoneOrCommentInputSheetViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.comment = textView.text ?? ""
        let isEmpty = viewModel.comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        placeholderLabel.isHidden = !isEmpty
        textView.layer.borderWidth = 1
        textView.layer.borderColor = isEmpty ? UIColor.systemRed.cgColor : UIColor.brightPurple.cgColor
    }
}
