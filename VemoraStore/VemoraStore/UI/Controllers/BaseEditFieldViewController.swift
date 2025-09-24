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

    var onBack: (() -> Void)?
    var onFinish: (() -> Void)?
    
    // MARK: - Deps

    let viewModel: BaseEditFieldViewModelProtocol
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Config

    private let fieldKind: FormTextFieldKind
    private let navTitle: String
    
    // MARK: - UI

    private lazy var field: FormTextField = {
        FormTextField(kind: fieldKind)
    }()
    
    private lazy var submitButton: BrandedButton = {
        let b = BrandedButton(style: .submit, title: "Изменить")
        b.isEnabled = false
        b.setNeedsUpdateConfiguration()
        b.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        return b
    }()
    
    private lazy var formStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [field, submitButton])
        sv.axis = .vertical
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // MARK: - Init

    init(viewModel: any BaseEditFieldViewModelProtocol,
         fieldKind: FormTextFieldKind,
         navTitle: String) {
        self.viewModel = viewModel
        self.fieldKind = fieldKind
        self.navTitle = navTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupNav()
        setupLayout()
        wire()
        bind()
        setupKeyboardDismissRecognizer()
    }
    
    // MARK: - Nav

    private func setupNav() {
        setupNavigationBarWithNavLeftItem(
            title: navTitle,
            action: #selector(backTapped),
            largeTitleDisplayMode: .never,
            prefersLargeTitles: false
        )
    }
    
    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(formStack)
        NSLayoutConstraint.activate([
            formStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            formStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            formStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    // MARK: - Wiring

    private func wire() {
        field.onTextChanged = { [weak self] in self?.viewModel.setValue($0) }
        field.textField.onReturn(self, action: #selector(submitFromKeyboard))
    }
    
    // MARK: - Bind

    private func bind() {
        viewModel.error
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.field.showError($0) }
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
    @objc private func submitFromKeyboard() { submitTapped() }
    
    @objc private func submitTapped() {
        Task {
            do {
                try await viewModel.submit()
                onFinish?()
            } catch {
                present(UIAlertController.makeError(error), animated: true)
            }
        }
    }
    
    // MARK: - Keyboard Dismissal

    private func setupKeyboardDismissRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc private func dismissKeyboard() { view.endEditing(true) }
}
