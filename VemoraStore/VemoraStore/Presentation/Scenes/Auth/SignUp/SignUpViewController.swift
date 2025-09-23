//
//  SignUpViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 19.09.2025.
//

import UIKit
import Combine

final class SignUpViewController: UIViewController {
    
    var onBack: (() -> Void)?
    var onOpenPrivacy: (() -> Void)?
    var onLogin: (() -> Void)?
    
    // MARK: - Dependencies
    
    private let viewModel: SignUpViewModelProtocol
    private var bag = Set<AnyCancellable>()
    
    // MARK: - UI
    
    private lazy var nameField: FormTextField = {
        let v = FormTextField(kind: .name)
        return v
    }()
    
    private lazy var emailField: FormTextField = {
        let v = FormTextField(kind: .email)
        return v
    }()
    
    private lazy var passwordField: FormTextField = {
        let v = FormTextField(kind: .password)
        return v
    }()
    
    private lazy var agreeCheck: UIButton = {
        let b = UIButton(type: .system)
        b.layer.cornerRadius = 5
        b.layer.borderWidth = 2
        b.layer.borderColor = UIColor.brightPurple.cgColor
        b.clipsToBounds = true
        if #available(iOS 15.0, *) {
            var conf = UIButton.Configuration.plain()
            conf.contentInsets = .zero
            b.configuration = conf
        }
        let markCfg = UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        b.setImage(UIImage(systemName: "checkmark", withConfiguration: markCfg), for: .selected)
        b.tintColor = .white
        return b
    }()
    
    private lazy var agreeButton: UIButton = {
        let b = UnderlinedButton(
            text: "Политика конфиденциальности",
            alignment: .leading
        )
        return b
    }()
    
    private lazy var agreeErrorLabel: UILabel = {
        let l = UILabel()
        l.textColor = .systemRed
        l.font = .systemFont(ofSize: 13)
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }()
    
    private lazy var submitButton: BrandedButton = {
        let b = BrandedButton(style: .submit, title: "Зарегистрироваться")
        b.isEnabled = false
        b.setNeedsUpdateConfiguration()
        return b
    }()
    
    private lazy var bottomNoteRow: LabelLinkRow = {
        let v = LabelLinkRow(label: "Уже есть аккаунт?", button: "Войти")
        v.onTap = { [weak self] in self?.onLogin?() }
        return v
    }()
    
    private lazy var agreeRow: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [agreeCheck, agreeButton])
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 10
        return sv
    }()
    
    private lazy var formStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            nameField,
            emailField,
            passwordField,
            agreeRow,
            agreeErrorLabel,
            submitButton,
            bottomNoteRow
        ])
        sv.axis = .vertical
        sv.spacing = 15
        return sv
    }()
    
    // MARK: - Init
    
    init(viewModel: SignUpViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupHierarchy()
        setupConstraints()
        updateAgreeCheckUI()
        wire()
        bind()
        setupKeyboardDismissRecognizer()
    }
    
    // MARK: - Layout
    
    private func setupHierarchy() {
        view.addSubview(formStack)
    }
    
    private func setupConstraints() {
        formStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            formStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70),
            formStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            formStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            formStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            formStack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
        
        NSLayoutConstraint.activate([
            agreeCheck.widthAnchor.constraint(equalToConstant: 20),
            agreeCheck.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    // MARK: - Wiring
    
    private func wire() {
        nameField.onTextChanged = { [weak self] in self?.viewModel.setName($0) }
        emailField.onTextChanged = { [weak self] in self?.viewModel.setEmail($0) }
        passwordField.onTextChanged = { [weak self] in self?.viewModel.setPassword($0) }
        
        nameField.textField.onReturn(self, action: #selector(focusEmailField))
        emailField.textField.onReturn(self, action: #selector(focusPasswordField))
        passwordField.textField.onReturn(self, action: #selector(submitFromKeyboard))
        
        agreeCheck.onTap(self, action: #selector(toggleAgree))
        agreeButton.onTap(self, action: #selector(privacyTapped))
        submitButton.onTap(self, action: #selector(submitTapped))
    }
    
    // MARK: - Bindings
    
    private func bind() {
        viewModel.nameError
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.nameField.showError($0) }
            .store(in: &bag)
        
        viewModel.emailError
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.emailField.showError($0) }
            .store(in: &bag)
        
        viewModel.passwordError
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.passwordField.showError($0) }
            .store(in: &bag)
        
        viewModel.agreementError
            .receive(on: RunLoop.main)
            .sink { [weak self] msg in
                self?.agreeErrorLabel.text = msg
                self?.agreeErrorLabel.isHidden = (msg == nil)
            }
            .store(in: &bag)
        
        viewModel.isSubmitEnabled
            .receive(on: RunLoop.main)
            .sink { [weak self] enabled in
                self?.submitButton.isEnabled = enabled
                self?.submitButton.setNeedsUpdateConfiguration() // <- ВАЖНО
            }
            .store(in: &bag)
    }
    
    private func updateAgreeCheckUI() {
        if #available(iOS 15.0, *) {
            var bg = UIBackgroundConfiguration.clear()
            bg.backgroundColor = agreeCheck.isSelected ? .brightPurple : .clear
            agreeCheck.configuration?.background = bg
        } else {
            agreeCheck.backgroundColor = agreeCheck.isSelected ? .brightPurple : .clear
        }
        agreeCheck.layer.borderColor = UIColor.brightPurple.cgColor
    }
    
    // MARK: - Actions
    
    @objc private func toggleAgree() {
        agreeCheck.isSelected.toggle()
        updateAgreeCheckUI()
        viewModel.setAgreement(agreeCheck.isSelected)
    }
    
    @objc private func privacyTapped() {
        onOpenPrivacy?()
    }
    
    @objc private func loginTapped() {
        onLogin?()
    }
    
    @objc private func submitTapped() {
        Task {
            do {
                try await viewModel.signUp()
            } catch {
                let errorAlert = UIAlertController.makeError(error)
                present(errorAlert, animated: true)
            }
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func focusEmailField() {
        emailField.textField.becomeFirstResponder()
    }
    
    @objc private func focusPasswordField() {
        passwordField.textField.becomeFirstResponder()
    }
    
    @objc private func submitFromKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Keyboard Dismissal
    
    private func setupKeyboardDismissRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}
