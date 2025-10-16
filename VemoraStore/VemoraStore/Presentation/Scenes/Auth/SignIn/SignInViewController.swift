//
//  SignInViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 21.09.2025.
//

import UIKit
import Combine

final class SignInViewController: UIViewController {
    
    // MARK: - Callbacks
    
    var onBack: (() -> Void)?
    var onOpenSignUp: (() -> Void)?
    var onForgotPassword: (() -> Void)?
    
    // MARK: - Dependencies
    
    private let viewModel: SignInViewModelProtocol
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 20
            static let verticalTop: CGFloat = 70
            static let verticalBottom: CGFloat = 24
        }
        
        enum Spacing {
            static let formSpacing: CGFloat = 15
        }
        
        enum Fonts {
            static let forgot: UIFont = .systemFont(ofSize: 15, weight: .regular)
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let forgotPasswordTitle = "Забыли пароль?"
        static let submitTitle = "Войти"
        static let noteText = "Ещё нет аккаунта?"
        static let noteAction = "Регистрация"
    }
    
    // MARK: - UI
    
    private lazy var emailField = FormTextField(kind: .email)
    private lazy var passwordField = FormTextField(kind: .password)
    
    private lazy var forgotButton: UIButton = {
        UnderlinedButton(
            text: Texts.forgotPasswordTitle,
            color: .brightPurple,
            font: Metrics.Fonts.forgot,
            alignment: .trailing
        )
    }()
    
    private lazy var forgotRowSpacer: UIView = {
        let spacer = UIView()
        return spacer
    }()
    
    private lazy var forgotRow: UIStackView = {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .fill
        row.distribution = .fill
        return row
    }()
    
    private lazy var submitButton: BrandedButton = {
        let b = BrandedButton(
            style: .submit,
            title: Texts.submitTitle
        )
        b.isEnabled = false
        b.setNeedsUpdateConfiguration()
        return b
    }()
    
    private lazy var bottomNoteRow: LabelLinkRow = {
        let row = LabelLinkRow(
            label: Texts.noteText,
            button: Texts.noteAction
        )
        row.onTap = { [weak self] in
            self?.openSignUp()
        }
        return row
    }()
    
    private lazy var formStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = Metrics.Spacing.formSpacing
        return sv
    }()
    
    // MARK: - Init
    
    init(viewModel: SignInViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupHierarchy()
        setupLayout()
        setupActions()
        wire()
        bind()
        setupKeyboardDismissRecognizer()
        setupAccessibility()
    }
}

// MARK: - Setup

private extension SignInViewController {
    func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    func setupHierarchy() {
        
        forgotRow.addArrangedSubviews(
            forgotRowSpacer,
            forgotButton
        )
        
        formStack.addArrangedSubviews(
            emailField,
            passwordField,
            forgotRow,
            submitButton,
            bottomNoteRow
        )
        
        view.addSubviews(formStack)
    }
    
    func setupLayout() {
        [formStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            formStack.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Metrics.Insets.verticalTop
            ),
            formStack.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Metrics.Insets.horizontal
            ),
            formStack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Metrics.Insets.horizontal
            ),
            formStack.bottomAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -Metrics.Insets.verticalBottom
            )
        ])
    }
    
    func setupActions() {
        emailField.textField.onReturn(self, action: #selector(focusPasswordField))
        passwordField.textField.onReturn(self, action: #selector(submitFromKeyboard))
        
        submitButton.onTap(self, action: #selector(submitTapped))
        forgotButton.onTap(self, action: #selector(forgotTapped))
    }
}

// MARK: - Wiring

private extension SignInViewController {
    func wire() {
        emailField.onTextChanged = { [weak self] in
            self?.viewModel.setEmail($0)
        }
        
        passwordField.onTextChanged = { [weak self] in
            self?.viewModel.setPassword($0)
        }
    }
}

// MARK: - Bindings

private extension SignInViewController {
    func bind() {
        viewModel.emailError
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.emailField.showError($0)
            }
            .store(in: &bag)
        
        viewModel.passwordError
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.passwordField.showError($0)
            }
            .store(in: &bag)
        
        viewModel.isSubmitEnabled
            .receive(on: RunLoop.main)
            .sink { [weak self] enabled in
                self?.submitButton.isEnabled = enabled
                self?.submitButton.setNeedsUpdateConfiguration()
            }
            .store(in: &bag)
    }
}

// MARK: - Actions

private extension SignInViewController {
    @objc func backTapped() {
        onBack?()
    }
    
    @objc func openSignUp() {
        onOpenSignUp?()
    }
    
    @objc func forgotTapped() {
        onForgotPassword?()
    }
    
    @objc func submitTapped() {
        Task {
            do {
                try await viewModel.signIn()
            } catch {
                let alert = UIAlertController.makeError(error)
                present(alert, animated: true)
            }
        }
    }
    
    @objc func focusPasswordField() {
        passwordField.textField.becomeFirstResponder()
    }
    
    @objc func submitFromKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Keyboard Dismissal

private extension SignInViewController {
    func setupKeyboardDismissRecognizer() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Accessibility

private extension SignInViewController {
    enum A11y {
        static let emailField  = "signin.email"
        static let passwordField = "signin.password"
        static let submitButton  = "signin.submit"
        static let forgotButton  = "signin.forgot"
    }
    
    func setupAccessibility() {
        emailField.textField.accessibilityIdentifier = A11y.emailField
        passwordField.textField.accessibilityIdentifier = A11y.passwordField
        submitButton.accessibilityIdentifier = A11y.submitButton
        forgotButton.accessibilityIdentifier = A11y.forgotButton
    }
}
