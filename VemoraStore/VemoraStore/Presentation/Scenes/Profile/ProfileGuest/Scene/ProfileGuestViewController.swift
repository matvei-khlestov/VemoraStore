//
//  ProfileGuestViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import UIKit

final class ProfileGuestViewController: UIViewController {
    
    // MARK: - Callbacks
    
    var onLoginTap:   (() -> Void)?
    var onAboutTap:   (() -> Void)?
    var onContactTap: (() -> Void)?
    var onPrivacyTap: (() -> Void)?
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 16
            static let verticalTop: CGFloat = 24
            static let verticalBottom: CGFloat = 24
        }
        enum Spacing {
            static let verticalStack: CGFloat = 16
            static let tableTopPadding: CGFloat = 8
        }
        enum Avatar {
            static let size: CGFloat = 96
        }
        enum Table {
            static let rowHeight: CGFloat = 56
            static let separatorInsets: UIEdgeInsets = .init(
                top: 0,
                left: 16,
                bottom: 0,
                right: 16
            )
        }
        enum Fonts {
            static let title: UIFont = .systemFont(ofSize: 22, weight: .semibold)
            static let subtitle: UIFont = .systemFont(ofSize: 15, weight: .regular)
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let navigationTitle = "Профиль"
        static let welcomeTitle = "Добро пожаловать"
        static let subtitle = "Зарегистрируйтесь или войдите в свой аккаунт, чтобы управлять сервисами Vemora"
        static let authButtonTitle = "Войти или зарегистрироваться"
    }
    
    // MARK: - Symbols
    
    private enum Symbols {
        static let avatarPlaceholder = "person.crop.circle"
    }
    
    // MARK: - UI
    
    private lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.alwaysBounceVertical = true
        return v
    }()
    
    private lazy var contentStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.alignment = .center
        v.spacing = Metrics.Spacing.verticalStack
        v.isLayoutMarginsRelativeArrangement = true
        v.directionalLayoutMargins = .init(
            top: Metrics.Insets.verticalTop,
            leading: Metrics.Insets.horizontal,
            bottom: Metrics.Insets.verticalBottom,
            trailing: Metrics.Insets.horizontal
        )
        return v
    }()
    
    private lazy var avatarView: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: Symbols.avatarPlaceholder))
        v.contentMode = .scaleAspectFit
        v.tintColor = .tertiaryLabel
        v.widthAnchor.constraint(equalToConstant: Metrics.Avatar.size).isActive = true
        v.heightAnchor.constraint(equalToConstant: Metrics.Avatar.size).isActive = true
        return v
    }()
    
    private lazy var welcomeLabel: UILabel = {
        let l = UILabel()
        l.text = Texts.welcomeTitle
        l.textAlignment = .center
        l.font = Metrics.Fonts.title
        return l
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = Texts.subtitle
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.font = Metrics.Fonts.subtitle
        return l
    }()
    
    private lazy var buttonContainer = UIView()
    
    private lazy var authButton: BrandedButton = {
        let b = BrandedButton(
            style: .primary,
            title: Texts.authButtonTitle
        )
        return b
    }()
    
    private lazy var tableContainer = UIView()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.isScrollEnabled = false
        tv.separatorInset = Metrics.Table.separatorInsets
        tv.rowHeight = Metrics.Table.rowHeight
        tv.dataSource = self
        tv.delegate   = self
        tv.register(ProfileRowCell.self)
        tv.tableFooterView = UIView()
        return tv
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupHierarchy()
        setupLayout()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(title: Texts.navigationTitle)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeightIfNeeded()
    }
}

// MARK: - Setup

private extension ProfileGuestViewController {
    func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    func setupHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        contentStack.addArrangedSubviews(
            avatarView,
            welcomeLabel,
            subtitleLabel,
            buttonContainer,
            tableContainer
        )
        
        buttonContainer.addSubview(authButton)
        tableContainer.addSubview(tableView)
    }
    
    func setupLayout() {
        prepareForAutoLayout()
        setupScrollConstraints()
        setupContentConstraints()
        setupWidthConstraints()
        setupButtonConstraints()
        setupTableConstraints()
    }
    
    func setupActions() {
        authButton.onTap(self, action: #selector(loginTapped))
    }
}

// MARK: - Layout

private extension ProfileGuestViewController {
    func prepareForAutoLayout() {
        [scrollView,
         contentStack,
         welcomeLabel,
         subtitleLabel,
         buttonContainer,
         authButton,
         tableContainer,
         tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupScrollConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            scrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            scrollView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])
    }
    
    func setupContentConstraints() {
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor
            ),
            contentStack.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor
            ),
            contentStack.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor
            ),
            contentStack.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor
            )
        ])
    }
    
    func setupWidthConstraints() {
        [welcomeLabel, subtitleLabel, buttonContainer, tableContainer].forEach {
            $0.widthAnchor.constraint(
                equalTo: contentStack.layoutMarginsGuide.widthAnchor
            ).isActive = true
        }
    }
    
    func setupButtonConstraints() {
        NSLayoutConstraint.activate([
            authButton.topAnchor.constraint(
                equalTo: buttonContainer.topAnchor
            ),
            authButton.leadingAnchor.constraint(
                equalTo: buttonContainer.leadingAnchor
            ),
            authButton.trailingAnchor.constraint(
                equalTo: buttonContainer.trailingAnchor
            ),
            authButton.bottomAnchor.constraint(
                equalTo: buttonContainer.bottomAnchor
            )
        ])
    }
    
    func setupTableConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: tableContainer.topAnchor,
                constant: Metrics.Spacing.tableTopPadding
            ),
            tableView.leadingAnchor.constraint(
                equalTo: tableContainer.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: tableContainer.trailingAnchor
            ),
            tableView.bottomAnchor.constraint(
                equalTo: tableContainer.bottomAnchor
            )
        ])
    }
    
    func updateTableHeightIfNeeded() {
        let desired = CGFloat(ProfileGuestRow.allCases.count) * tableView.rowHeight
        + Metrics.Spacing.tableTopPadding
        tableView.constraints
            .filter { $0.firstAttribute == .height }
            .forEach { $0.isActive = false }
        tableView.heightAnchor.constraint(equalToConstant: desired).isActive = true
    }
}

// MARK: - Actions

private extension ProfileGuestViewController {
    @objc func loginTapped() {
        onLoginTap?()
    }
}

// MARK: - UITableViewDataSource

extension ProfileGuestViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ProfileGuestRow.allCases.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = ProfileGuestRow(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        let cell: ProfileRowCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(title: row.title, systemImage: row.systemImage)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ProfileGuestViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = ProfileGuestRow(rawValue: indexPath.row) else { return }
        switch row {
        case .about:
            onAboutTap?()
        case .contact:
            onContactTap?()
        case .privacy:
            onPrivacyTap?()
        }
    }
}
