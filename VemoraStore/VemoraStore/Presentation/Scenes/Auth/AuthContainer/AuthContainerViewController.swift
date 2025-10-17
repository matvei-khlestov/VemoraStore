//
//  AuthContainerViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 21.09.2025.
//

import UIKit

/// Контейнер-контроллер `AuthContainerViewController` для экранов аутентификации.
///
/// Отвечает за:
/// - переключение режимов между `SignInViewController` и `SignUpViewController`;
/// - управление заголовком и стилем навигации в зависимости от режима;
/// - маршрутизацию событий наружу через колбэки:
///   `onBack`, `onOpenPrivacy`, `onForgotPassword`;
/// - анимированную смену дочерних контроллеров (кросс-фейд).
///
/// Особенности:
/// - инкапсулирует attach/detach child-VC и их раскладку по safe area;
/// - предотвращает лишние пересоздания при повторном выборе того же режима;
/// - бизнес-логика регистрации/входа находится во вложенных VC и их ViewModel.

final class AuthContainerViewController: UIViewController {
    
    // MARK: - Mode
    
    enum Mode { case signIn, signUp }
    
    // MARK: - Callbacks
    
    var onBack: (() -> Void)?
    var onOpenPrivacy: (() -> Void)?
    var onForgotPassword: (() -> Void)?
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 0
            static let verticalTop: CGFloat = 0
            static let verticalBottom: CGFloat = 0
        }
        enum Durations {
            static let crossfade: TimeInterval = 0.25
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let signInTitle = "Вход"
        static let signUpTitle = "Регистрация"
    }
    
    // MARK: - Dependencies
    
    private let signInVC: SignInViewController
    private let signUpVC: SignUpViewController
    
    // MARK: - State
    
    private var current: UIViewController?
    private var mode: Mode = .signIn
    
    // MARK: - Init
    
    init(
        signIn: SignInViewController,
        signUp: SignUpViewController,
        start mode: Mode = .signIn
    ) {
        self.signInVC = signIn
        self.signUpVC = signUp
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
        setupChildCallbacks()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setMode(mode, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationBar(for: mode)
    }
    
    // MARK: - Setup
    
    private func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    private func setupChildCallbacks() {
        // События из Sign In
        signInVC.onOpenSignUp = { [weak self] in
            self?.setMode(.signUp, animated: true)
        }
        signInVC.onBack = { [weak self] in
            self?.onBack?() }
        signInVC.onForgotPassword = { [weak self] in
            self?.onForgotPassword?() }
        
        // События из Sign Up
        signUpVC.onLogin = { [weak self] in
            self?.setMode(.signIn, animated: true)
        }
        signUpVC.onBack = { [weak self] in
            self?.onBack?()
        }
        signUpVC.onOpenPrivacy = { [weak self] in
            self?.onOpenPrivacy?()
        }
    }
    
    private func updateNavigationBar(for mode: Mode) {
        let title = (mode == .signIn) ? Texts.signInTitle : Texts.signUpTitle
        setupNavigationBar(
            title: title,
            largeTitleDisplayMode: .always,
            prefersLargeTitles: true
        )
        navigationItem.hidesBackButton = true
    }
    
    // MARK: - Public
    
    func setMode(_ mode: Mode, animated: Bool) {
        self.mode = mode
        let target = (mode == .signIn) ? signInVC : signUpVC
        swapChild(to: target, animated: animated)
        updateNavigationBar(for: mode)
    }
    
    // MARK: - Child Management
    
    private func swapChild(to newVC: UIViewController, animated: Bool) {
        guard current !== newVC else { return }
        let oldVC = current
        
        attach(newVC)
        layoutChildView(newVC.view)
        
        if animated, let fromView = oldVC?.view {
            current = newVC
            crossfade(from: fromView, to: newVC.view) { [weak self, weak oldVC] in
                self?.detach(oldVC)
                if let mode = self?.mode {
                    self?.updateNavigationBar(for: mode)
                }
            }
        } else {
            detach(oldVC)
            current = newVC
        }
    }
    
    private func attach(_ vc: UIViewController) {
        addChild(vc)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    private func layoutChildView(_ childView: UIView) {
        NSLayoutConstraint.activate([
            childView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Metrics.Insets.verticalTop
            ),
            childView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Metrics.Insets.horizontal
            ),
            childView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Metrics.Insets.horizontal
            ),
            childView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -Metrics.Insets.verticalBottom
            )
        ])
    }
    
    private func detach(_ vc: UIViewController?) {
        guard let vc else { return }
        vc.willMove(toParent: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParent()
    }
    
    private func crossfade(
        from: UIView,
        to: UIView,
        completion: @escaping () -> Void
    ) {
        UIView.transition(
            from: from,
            to: to,
            duration: Metrics.Durations.crossfade,
            options: [
                .transitionCrossDissolve,
                .showHideTransitionViews
            ],
            completion: { _ in completion() }
        )
    }
    
    // MARK: - Actions
    
    @objc private func backTapped() {
        onBack?()
    }
}
