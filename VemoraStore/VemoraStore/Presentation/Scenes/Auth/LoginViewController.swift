//
//  LoginViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit
import Combine
import FactoryKit

final class LoginViewController: UIViewController {
    
    // MARK: - Deps
    private let viewModel: LoginViewModel
    
    // MARK: - UI
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Vemora Store"
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textAlignment = .center
        return l
    }()
    
    private let emailField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.returnKeyType = .next
        return tf
    }()
    
    private let passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Пароль"
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.returnKeyType = .done
        return tf
    }()
    
    private lazy var loginButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Войти", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.backgroundColor = .systemBlue
        b.tintColor = .white
        b.layer.cornerRadius = 10
        b.heightAnchor.constraint(equalToConstant: 44).isActive = true
        b.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return b
    }()
    
    private lazy var registerButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Зарегистрироваться", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.backgroundColor = .systemGreen
        b.tintColor = .white
        b.layer.cornerRadius = 10
        b.heightAnchor.constraint(equalToConstant: 44).isActive = true
        b.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        return b
    }()
    
    private let errorLabel: UILabel = {
        let l = UILabel()
        l.textColor = .systemRed
        l.font = .systemFont(ofSize: 13)
        l.numberOfLines = 0
        l.isHidden = true
        l.textAlignment = .center
        return l
    }()
    
    private let activity = UIActivityIndicatorView(style: .medium)
    
    private let stack = UIStackView()
    
    // MARK: - State
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    init(viewModel: LoginViewModel = Container.shared.loginViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        setupTextFieldTargets()
        bindViewModel()
    }
}

// MARK: - Layout & Bindings
private extension LoginViewController {
    func setupLayout() {
        stack.axis = .vertical
        stack.spacing = 12
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(top: 24, left: 20, bottom: 24, right: 20)
        
        [titleLabel, emailField, passwordField, loginButton, registerButton, errorLabel, activity]
            .forEach { stack.addArrangedSubview($0) }
        
        // центр по вертикали с ограниченной шириной
        let container = UIView()
        container.addSubview(stack)
        view.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            container.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            emailField.heightAnchor.constraint(equalToConstant: 44),
            passwordField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func setupTextFieldTargets() {
        emailField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    func bindViewModel() {
        // error
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.errorLabel.text = message
                self?.errorLabel.isHidden = (message == nil)
            }
            .store(in: &bag)
        
        // loading
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                loading ? self?.activity.startAnimating() : self?.activity.stopAnimating()
                self?.loginButton.isEnabled = !loading
                self?.registerButton.isEnabled = !loading
                self?.loginButton.alpha = loading ? 0.6 : 1.0
                self?.registerButton.alpha = loading ? 0.6 : 1.0
            }
            .store(in: &bag)
        
        // При желании можно слушать isAuthorized, но AuthCoordinator уже подписывается
        // viewModel.$isAuthorized ...
    }
}

// MARK: - Actions
private extension LoginViewController {
    @objc func textChanged(_ sender: UITextField) {
        if sender === emailField {
            viewModel.email = sender.text ?? ""
        } else if sender === passwordField {
            viewModel.password = sender.text ?? ""
        }
    }
    
    @objc func loginTapped() {
        view.endEditing(true)
        viewModel.login()
    }
    
    @objc func registerTapped() {
        view.endEditing(true)
        viewModel.register()
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === emailField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            viewModel.login()
        }
        return true
    }
}
