//
//  BaseEditFieldViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import UIKit
import Combine

class BaseEditFieldViewController: UIViewController {
    
    // MARK: - Callbacks
    
    var onBack:   (() -> Void)?
    var onFinish: (() -> Void)?
    
    // MARK: - Deps
    
    private let viewModel: BaseEditFieldViewModelProtocol
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Config
    
    private let fieldKind: FormTextFieldKind
    private let navTitle: String
    private let phoneFormatter: PhoneFormattingProtocol?
    
    // MARK: - Constants
    
    private enum Metrics {
        enum Insets {
            static let content = NSDirectionalEdgeInsets(
                top: 60, leading: 16, bottom: 24, trailing: 16
            )
        }
        
        enum Spacing {
            static let formVertical: CGFloat = 16
        }
    }
    
    private enum Texts {
        static let submitButtonTitle = "Изменить"
    }
    
    // MARK: - UI
    
    private lazy var field: FormTextField = {
        FormTextField(
            kind: fieldKind,
            phoneFormatter: phoneFormatter
        )
    }()
    
    private lazy var submitButton: BrandedButton = {
        let b = BrandedButton(style: .submit, title: Texts.submitButtonTitle)
        b.isEnabled = false
        b.setNeedsUpdateConfiguration()
        b.onTap(self, action: #selector(submitTapped))
        return b
    }()
    
    private let formStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.alignment = .fill
        v.spacing = Metrics.Spacing.formVertical
        v.isLayoutMarginsRelativeArrangement = true
        v.directionalLayoutMargins = Metrics.Insets.content
        return v
    }()
    
    // MARK: - Init
    
    init(
        viewModel: BaseEditFieldViewModelProtocol,
        fieldKind: FormTextFieldKind,
        navTitle: String,
        phoneFormatter: PhoneFormattingProtocol? = nil
    ) {
        self.viewModel = viewModel
        self.fieldKind = fieldKind
        self.navTitle = navTitle
        self.phoneFormatter = phoneFormatter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupNav()
        setupHierarchy()
        setupLayout()
        wire()
        bind()
        setupKeyboardDismissRecognizer()
    }
}

// MARK: - Setup

private extension BaseEditFieldViewController {
    func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    func setupNav() {
        setupNavigationBarWithNavLeftItem(
            title: navTitle,
            action: #selector(backTapped),
            largeTitleDisplayMode: .never,
            prefersLargeTitles: false
        )
    }
    
    func setupHierarchy() {
        formStack.addArrangedSubviews(field, submitButton)
        view.addSubview(formStack)
    }
    
    func setupLayout() {
        formStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            formStack.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            formStack.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            formStack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            )
        ])
    }
    
    func wire() {
        field.onTextChanged = { [weak self] in
            self?.viewModel.setValue($0)
        }
        field.textField.onReturn(self, action: #selector(submitFromKeyboard))
    }
    
    private func bind() {
        viewModel.error
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.field.showError($0)
            }
            .store(in: &bag)
        
        viewModel.isSubmitEnabled
            .receive(on: RunLoop.main)
            .sink { [weak self] enabled in
                self?.submitButton.isEnabled = enabled
                self?.submitButton.setNeedsUpdateConfiguration()
            }
            .store(in: &bag)
        
        if let nameVM = viewModel as? EditNameViewModelProtocol {
            bindField(nameVM.namePublisher) { [weak self] value in
                self?.field.textField.text = value
            }
        }
        
        if let emailVM = viewModel as? EditEmailViewModelProtocol {
            bindField(emailVM.emailPublisher) { [weak self] value in
                self?.field.textField.text = value
            }
        }
        
        if let phoneVM = viewModel as? EditPhoneViewModelProtocol {
            bindField(phoneVM.phonePublisher) { [weak self] value in
                self?.field.setPhoneE164(value)
            }
        }
    }
    
    /// Универсальная привязка значения к полю, если поле не в фокусе
    private func bindField(_ publisher: AnyPublisher<String, Never>,
                           update: @escaping (String) -> Void) {
        publisher
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                guard let self, self.field.textField.isFirstResponder == false else { return }
                update(value)
            }
            .store(in: &bag)
    }
}

// MARK: - Keyboard Dismissal

private extension BaseEditFieldViewController {
    func setupKeyboardDismissRecognizer() {
        let tap = UITapGestureRecognizer(
            target: self, action: #selector(dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Actions

@objc private extension BaseEditFieldViewController {
    func backTapped() {
        onBack?()
    }
    
    func submitFromKeyboard() {
        submitTapped()
    }
    
    func submitTapped() {
        Task {
            do {
                try await viewModel.submit()
                onFinish?()
            } catch {
                present(UIAlertController.makeError(error), animated: true)
            }
        }
    }
}
