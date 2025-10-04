//
//  SignUpViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 19.09.2025.
//

import UIKit
import Combine

final class SignUpViewController: UIViewController {
    
    // MARK: - Callbacks
    
    var onBack: (() -> Void)?
    var onOpenPrivacy: (() -> Void)?
    var onLogin: (() -> Void)?
    
    // MARK: - Dependencies
    
    private let viewModel: SignUpViewModelProtocol
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
            static let agreeRow: CGFloat = 10
        }
        
        enum Checkbox {
            static let size: CGFloat = 20
            static let cornerRadius: CGFloat = 5
            static let borderWidth: CGFloat = 2
            static let checkmarkPoint: CGFloat = 10
        }
        
        enum Fonts {
            static let agreeError: UIFont = .systemFont(ofSize: 13, weight: .regular)
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let privacyTitle = "Политика конфиденциальности"
        static let submitTitle  = "Зарегистрироваться"
        static let noteText     = "Уже есть аккаунт?"
        static let noteAction   = "Войти"
    }
    
    // MARK: - UI
    
    private lazy var nameField = FormTextField(kind: .name)
    private lazy var emailField = FormTextField(kind: .email)
    private lazy var passwordField = FormTextField(kind: .password)
    
    private lazy var agreeCheck: UIButton = {
        let b = UIButton(type: .system)
        b.layer.cornerRadius = Metrics.Checkbox.cornerRadius
        b.layer.borderWidth = Metrics.Checkbox.borderWidth
        b.layer.borderColor = UIColor.brightPurple.cgColor
        b.clipsToBounds = true
        if #available(iOS 15.0, *) {
            var conf = UIButton.Configuration.plain()
            conf.contentInsets = .zero
            b.configuration = conf
        }
        let markCfg = UIImage.SymbolConfiguration(
            pointSize: Metrics.Checkbox.checkmarkPoint,
            weight: .medium
        )
        b.setImage(UIImage(
            systemName: "checkmark",
            withConfiguration: markCfg
        ), for: .selected)
        b.tintColor = .white
        return b
    }()
    
    private lazy var agreeButton: UIButton = {
        UnderlinedButton(
            text: Texts.privacyTitle,
            alignment: .leading
        )
    }()
    
    private lazy var agreeErrorLabel: UILabel = {
        let l = UILabel()
        l.textColor = .systemRed
        l.font = Metrics.Fonts.agreeError
        l.numberOfLines = 0
        l.isHidden = true
        return l
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
        let v = LabelLinkRow(
            label: Texts.noteText,
            button: Texts.noteAction
        )
        v.onTap = { [weak self] in
            self?.onLogin?()
        }
        return v
    }()
    
    private lazy var agreeRow: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = Metrics.Spacing.agreeRow
        return sv
    }()
    
    private lazy var formStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = Metrics.Spacing.formSpacing
        return sv
    }()
    
    // MARK: - Init
    
    init(viewModel: SignUpViewModelProtocol) {
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
        updateAgreeCheckUI()
        wire()
        bind()
        setupKeyboardDismissRecognizer()
        nameField.textField.text = "John"
        emailField.textField.text = "john@example.com"
        passwordField.textField.text = "123456jddj!Nhhhh"
    }
}

// MARK: - Setup

private extension SignUpViewController {
    func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    func setupHierarchy() {
        agreeRow.addArrangedSubviews(
            agreeCheck,
            agreeButton
        )
        
        formStack.addArrangedSubviews(
            nameField,
            emailField,
            passwordField,
            agreeRow,
            agreeErrorLabel,
            submitButton,
            bottomNoteRow
        )
        
        view.addSubviews(formStack)
    }
    
    func setupLayout() {
        [formStack, agreeCheck].forEach {
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
            ),
            
            agreeCheck.widthAnchor.constraint(
                equalToConstant: Metrics.Checkbox.size
            ),
            agreeCheck.heightAnchor.constraint(
                equalToConstant: Metrics.Checkbox.size
            )
        ])
    }
    
    func setupActions() {
        nameField.textField.onReturn(self, action: #selector(focusEmailField))
        emailField.textField.onReturn(self, action: #selector(focusPasswordField))
        passwordField.textField.onReturn(self, action: #selector(submitFromKeyboard))
        
        agreeCheck.onTap(self, action: #selector(toggleAgree))
        agreeButton.onTap(self, action: #selector(privacyTapped))
        submitButton.onTap(self, action: #selector(submitTapped))
    }
}

// MARK: - Wiring

private extension SignUpViewController {
    func wire() {
        nameField.onTextChanged = { [weak self] in
            self?.viewModel.setName($0)
        }
        emailField.onTextChanged = { [weak self] in
            self?.viewModel.setEmail($0)
        }
        passwordField.onTextChanged = { [weak self] in
            self?.viewModel.setPassword($0)
        }
    }
}

// MARK: - Bindings

private extension SignUpViewController {
    func bind() {
        viewModel.nameError
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.nameField.showError($0)
            }
            .store(in: &bag)
        
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
                self?.submitButton.setNeedsUpdateConfiguration()
            }
            .store(in: &bag)
    }
}

// MARK: - UI State

private extension SignUpViewController {
    func updateAgreeCheckUI() {
        if #available(iOS 15.0, *) {
            var bg = UIBackgroundConfiguration.clear()
            bg.backgroundColor = agreeCheck.isSelected ? .brightPurple : .clear
            agreeCheck.configuration?.background = bg
        } else {
            agreeCheck.backgroundColor = agreeCheck.isSelected ? .brightPurple : .clear
        }
        agreeCheck.layer.borderColor = UIColor.brightPurple.cgColor
    }
}

// MARK: - Actions

private extension SignUpViewController {
    @objc func backTapped() {
        onBack?()
    }
    
    @objc func toggleAgree() {
        agreeCheck.isSelected.toggle()
        updateAgreeCheckUI()
        viewModel.setAgreement(agreeCheck.isSelected)
    }
    
    @objc func privacyTapped() {
        onOpenPrivacy?()
    }
    @objc func loginTapped() {
        onLogin?()
    }
    
    @objc func submitTapped() {
        Task {
            do {
                try await viewModel.signUp()
            } catch {
                let alert = UIAlertController.makeError(error)
                present(alert, animated: true)
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    @objc func focusEmailField() {
        emailField.textField.becomeFirstResponder()
    }
    @objc func focusPasswordField() {
        passwordField.textField.becomeFirstResponder()
    }
    @objc func submitFromKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Keyboard Dismissal

private extension SignUpViewController {
    func setupKeyboardDismissRecognizer() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}
