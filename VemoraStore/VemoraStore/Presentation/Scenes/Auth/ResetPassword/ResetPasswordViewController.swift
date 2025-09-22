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
    
    // MARK: - Deps
    private let viewModel: ResetPasswordViewModelProtocol
    private var bag = Set<AnyCancellable>()
    
    // MARK: - UI
    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Восстановление пароля"
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.numberOfLines = 0
        return l
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Укажите e-mail, мы отправим ссылку для смены пароля."
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }()
    
    private lazy var emailField: FormTextField = {
        FormTextField(kind: .email)
    }()
    
    private lazy var submitButton: BrandedButton = {
        let b = BrandedButton(style: .submit, title: "Отправить")
        b.isEnabled = false
        b.setNeedsUpdateConfiguration()
        b.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        return b
    }()
    
    private lazy var backNoteRow: LabelLinkRow = {
        let row = LabelLinkRow(label: "Вспомнили пароль?", button: "Назад ко входу")
        row.onTap = { [weak self] in self?.backTapped() }
        return row
    }()
    
    private lazy var formStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel,
            emailField,
            submitButton,
            backNoteRow
        ])
        sv.axis = .vertical
        sv.spacing = 18
        return sv
    }()
    
    // MARK: - Init
    init(viewModel: ResetPasswordViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNav()
        layout()
        wire()
        bind()
        setupKeyboardDismiss()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNav()
    }
    
    // MARK: - Private Methods
    private func setupNav() {
        setupNavigationBarWithNavLeftItem(
            action: #selector(backTapped),
            largeTitleDisplayMode: .never,
            prefersLargeTitles: false
        )
    }
    
    private func layout() {
        view.addSubview(formStack)
        formStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            formStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            formStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            formStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            formStack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }
    
    private func wire() {
        emailField.onTextChanged = { [weak self] in self?.viewModel.setEmail($0) }
        emailField.textField.addTarget(self, action: #selector(submitFromKeyboard), for: .editingDidEndOnExit)
    }
    
    private func bind() {
        viewModel.emailError
            .receive(on: RunLoop.main)
            .sink { [weak self] msg in self?.emailField.showError(msg) }
            .store(in: &bag)
        
        viewModel.isSubmitEnabled
            .receive(on: RunLoop.main)
            .sink { [weak self] enabled in
                self?.submitButton.isEnabled = enabled
                self?.submitButton.setNeedsUpdateConfiguration()
            }
            .store(in: &bag)
    }
    
    private func setupKeyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // MARK: - Actions
    @objc private func backTapped() { onBack?() }
    
    @objc private func submitTapped() {
        Task {
            do {
                try await viewModel.resetPassword()
                let ac = UIAlertController.makeInfo(
                    title: "Готово",
                    message: "Мы отправили письмо. Проверьте почту.",
                    onOk: { [weak self] in
                        self?.onDone?() ?? self?.onBack?()
                    }
                )
                present(ac, animated: true)
            } catch {
                let ac = UIAlertController.makeError(error)
                present(ac, animated: true)
            }
        }
    }
    
    @objc private func submitFromKeyboard() {
        view.endEditing(true)
        if submitButton.isEnabled { submitTapped() }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
