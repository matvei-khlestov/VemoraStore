//
//  ResetPasswordViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 21.09.2025.
//

import UIKit
import Combine

final class ResetPasswordViewController: UIViewController {
    
    // MARK: - Callbacks
    
    var onBack: (() -> Void)?
    var onDone: (() -> Void)?
    
    // MARK: - Dependencies
    
    private let viewModel: ResetPasswordViewModelProtocol
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 20
            static let verticalTop: CGFloat = 70
            static let verticalBottom: CGFloat = 24
        }
        
        enum Spacing {
            static let form: CGFloat = 18
        }
        
        enum Fonts {
            static let title: UIFont = .systemFont(ofSize: 28, weight: .bold)
            static let subtitle: UIFont = .systemFont(ofSize: 15, weight: .regular)
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let title = "Восстановление пароля"
        static let subtitle = "Укажите e-mail, мы отправим ссылку для смены пароля."
        static let submit = "Отправить"
        static let backRowLabel = "Вспомнили пароль?"
        static let backRowButton = "Назад ко входу"
        static let alertTitleDone = "Готово"
        static let alertMessageSent = "Мы отправили письмо. Проверьте почту."
    }
    
    // MARK: - UI
    
    private lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.text = Texts.title
        v.font = Metrics.Fonts.title
        v.textColor = .label
        v.numberOfLines = 0
        return v
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let v = UILabel()
        v.text = Texts.subtitle
        v.font = Metrics.Fonts.subtitle
        v.textColor = .secondaryLabel
        v.numberOfLines = 0
        return v
    }()
    
    private lazy var emailField = FormTextField(kind: .email)
    
    private lazy var submitButton: BrandedButton = {
        let b = BrandedButton(style: .submit, title: Texts.submit)
        b.isEnabled = false
        b.setNeedsUpdateConfiguration()
        b.onTap(self, action: #selector(submitTapped))
        return b
    }()
    
    private lazy var backNoteRow: LabelLinkRow = {
        let row = LabelLinkRow(
            label: Texts.backRowLabel,
            button: Texts.backRowButton
        )
        row.onTap = { [weak self] in
            self?.backTapped()
        }
        return row
    }()
    
    private lazy var formStack: UIStackView = {
        let v = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            emailField,
            submitButton,
            backNoteRow
        ])
        v.axis = .vertical
        v.spacing = Metrics.Spacing.form
        return v
    }()
    
    // MARK: - Init
    
    init(viewModel: ResetPasswordViewModelProtocol) {
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
        setupNavigationBar()
        setupHierarchy()
        setupLayout()
        wire()
        bind()
        setupKeyboardDismissRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
}

// MARK: - Setup

private extension ResetPasswordViewController {
    func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    func setupNavigationBar() {
        setupNavigationBarWithNavLeftItem(
            action: #selector(backTapped),
            largeTitleDisplayMode: .never,
            prefersLargeTitles: false
        )
    }
    
    func setupHierarchy() {
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
}

// MARK: - Wiring

private extension ResetPasswordViewController {
    func wire() {
        emailField.onTextChanged = { [weak self] in
            self?.viewModel.setEmail($0)
        }
        emailField.textField.onReturn(self, action: #selector(submitFromKeyboard))
    }
}

// MARK: - Bindings

private extension ResetPasswordViewController {
    func bind() {
        viewModel.emailError
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.emailField.showError($0)
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

// MARK: - Keyboard Dismissal

private extension ResetPasswordViewController {
    func setupKeyboardDismissRecognizer() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}

// MARK: - Actions

private extension ResetPasswordViewController {
    @objc func backTapped() {
        onBack?()
    }
    
    @objc func submitTapped() {
        view.endEditing(true)
        Task {
            do {
                try await viewModel.resetPassword()
                let ac = UIAlertController.makeInfo(
                    title: Texts.alertTitleDone,
                    message: Texts.alertMessageSent,
                    onOk: { [weak self] in
                        self?.onDone?() ?? self?.onBack?()
                    }
                )
                present(ac, animated: true)
            } catch {
                present(UIAlertController.makeError(error), animated: true)
            }
        }
    }
    
    @objc func submitFromKeyboard() {
        view.endEditing(true)
        if submitButton.isEnabled {
            submitTapped()
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
