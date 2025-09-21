//
//  AuthContainerViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 21.09.2025.
//

import UIKit

final class AuthContainerViewController: UIViewController {
    enum Mode { case signIn, signUp }

    // MARK: - Public callbacks
    
    var onFinish: (() -> Void)?
    var onOpenPrivacy: (() -> Void)?
    var onForgotPassword: (() -> Void)?

    // MARK: - Private Properties
    
    private let signInVC: SignInViewController
    private let signUpVC: SignUpViewController
    private var current: UIViewController?

    // MARK: - Init
    
    init(
        signIn: SignInViewController,
        signUp: SignUpViewController,
        start mode: Mode = .signIn
    ) {
        self.signInVC = signIn
        self.signUpVC = signUp
        super.init(nibName: nil, bundle: nil)
        setupCallbacks(startMode: mode)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupCallbacks(startMode mode: Mode) {
        // события из детей
        signInVC.onOpenSignUp     = { [weak self] in self?.setMode(.signUp, animated: true) }
        signInVC.onBack           = { [weak self] in self?.onFinish?() }
        signInVC.onForgotPassword = { [weak self] in self?.onForgotPassword?() }

        signUpVC.onLogin       = { [weak self] in self?.setMode(.signIn, animated: true) }
        signUpVC.onBack        = { [weak self] in self?.onFinish?() }
        signUpVC.onOpenPrivacy = { [weak self] in self?.onOpenPrivacy?() }

        setMode(mode, animated: false)
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let currentTitle = (current === signInVC) ? "Вход" : "Регистрация"
        setupNavigationBarWithNavLeftItem(
            title: currentTitle,
            action: #selector(backTapped),
            largeTitleDisplayMode: .always,
            prefersLargeTitles: true
        )
    }

    // MARK: - Public Methods
    
    func setMode(_ mode: Mode, animated: Bool) {
        let target = (mode == .signIn) ? signInVC : signUpVC
        title = (mode == .signIn) ? "Вход" : "Регистрация"
        swapChild(to: target, animated: animated)
    }

    // MARK: - Private Methods
    
    private func swapChild(to newVC: UIViewController, animated: Bool) {
        let oldVC = current
        guard oldVC !== newVC else { return }

        addChild(newVC)
        newVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newVC.view)
        NSLayoutConstraint.activate([
            newVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            newVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        newVC.didMove(toParent: self)

        let removeOld = {
            oldVC?.willMove(toParent: nil)
            oldVC?.view.removeFromSuperview()
            oldVC?.removeFromParent()
        }

        if animated, let oldView = oldVC?.view {
            UIView.transition(from: oldView,
                              to: newVC.view,
                              duration: 0.25,
                              options: [.transitionCrossDissolve, .showHideTransitionViews]) { _ in
                self.current = newVC
                removeOld()
            }
        } else {
            removeOld()
            current = newVC
        }
    }
    
    // MARK: - Actions
    
    @objc private func backTapped() {
        onFinish?()
    }
}
