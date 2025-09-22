//
//  SignInViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 21.09.2025.
//

import UIKit
import Combine

final class SignInViewController: UIViewController {
    
    // MARK: - Public callbacks
    
    var onBack: (() -> Void)?
    var onOpenSignUp: (() -> Void)?
    var onForgotPassword: (() -> Void)?
    
    // MARK: - Dependencies
    
    private let viewModel: SignInViewModelProtocol
    private var bag = Set<AnyCancellable>()
    
    // MARK: - UI
    
    private lazy var emailField: FormTextField = {
        FormTextField(kind: .email)
    }()
    
    private lazy var passwordField: FormTextField = {
        FormTextField(kind: .password)
    }()
    
    private lazy var forgotButton: UIButton = {
        let b = UnderlinedButton(
            text: "Забыли пароль?",
            color: .brightPurple,
            font: .systemFont(ofSize: 15),
            alignment: .trailing
        )
        return b
    }()
    
    private lazy var forgotRow: UIStackView = {
        let spacer = UIView()
        let sv = UIStackView(arrangedSubviews: [spacer, forgotButton])
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var submitButton: BrandedButton = {
        let b = BrandedButton(style: .submit, title: "Войти")
        b.isEnabled = false
        b.setNeedsUpdateConfiguration()
        return b
    }()
    
    private lazy var bottomNoteRow: LabelLinkRow = {
        let row = LabelLinkRow(
            label: "Ещё нет аккаунта?",
            button: "Регистрация"
        )
        row.onTap = { [weak self] in self?.openSignUp() }
        return row
    }()
    
    private lazy var formStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            emailField,
            passwordField,
            forgotRow,
            submitButton,
            bottomNoteRow
        ])
        sv.axis = .vertical
        sv.spacing = 15
        return sv
    }()
    
    // MARK: - Init
    
    init(viewModel: SignInViewModelProtocol) {
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
    }
    
    // MARK: - Wiring
    
    private func wire() {
        emailField.onTextChanged = { [weak self] in self?.viewModel.setEmail($0) }
        passwordField.onTextChanged = { [weak self] in self?.viewModel.setPassword($0) }
        
        emailField.textField.onReturn(self, action: #selector(focusPasswordField))
        passwordField.textField.onReturn(self, action: #selector(submitFromKeyboard))
        
        submitButton.onTap(self, action: #selector(submitTapped))
        forgotButton.onTap(self, action: #selector(forgotTapped))
    }
    
    // MARK: - Bindings
    
    private func bind() {
        viewModel.emailError
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.emailField.showError($0) }
            .store(in: &bag)
        
        viewModel.passwordError
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.passwordField.showError($0) }
            .store(in: &bag)
        
        viewModel.isSubmitEnabled
            .receive(on: RunLoop.main)
            .sink { [weak self] enabled in
                self?.submitButton.isEnabled = enabled
                self?.submitButton.setNeedsUpdateConfiguration()
            }
            .store(in: &bag)
    }
    
    // MARK: - Actions
    
    @objc private func backTapped() { onBack?() }
    
    @objc private func openSignUp() { onOpenSignUp?() }
    
    @objc private func forgotTapped() { onForgotPassword?() }
    
    @objc private func submitTapped() {
        Task {
            do {
                try await viewModel.signIn()
            } catch {
                let ac = UIAlertController(title: "Ошибка",
                                           message: error.localizedDescription,
                                           preferredStyle: .alert)
                ac.addAction(.init(title: "Ок", style: .default))
                present(ac, animated: true)
            }
        }
    }
    
    @objc private func focusPasswordField() { passwordField.textField.becomeFirstResponder() }
    @objc private func submitFromKeyboard() { view.endEditing(true) }
    
    // MARK: - Keyboard Dismissal
    
    private func setupKeyboardDismissRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc private func dismissKeyboard() { view.endEditing(true) }
}
