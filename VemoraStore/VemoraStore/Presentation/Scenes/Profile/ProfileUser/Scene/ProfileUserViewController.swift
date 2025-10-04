//
//  ProfileUserViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 17.09.2025.
//

import UIKit
import Combine

final class ProfileUserViewController: UIViewController {
    
    // MARK: - Callbacks
    
    var onEditProfileTap:   (() -> Void)?
    var onOrdersTap:        (() -> Void)?
    var onAboutTap:         (() -> Void)?
    var onContactTap:       (() -> Void)?
    var onPrivacyTap:       (() -> Void)?
    var onLogoutTap:        (() -> Void)?
    var onDeleteAccountTap: (() -> Void)?
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Avatar {
            static let size: CGFloat = 96
        }
        
        enum Spacing {
            static let verticalStack: CGFloat = 20
            static let actionsStack: CGFloat = 12
            static let tableTopPadding: CGFloat = 8
        }
        
        enum Insets {
            static let contentInsets = NSDirectionalEdgeInsets(
                top: 24,
                leading: 16,
                bottom: 24,
                trailing: 16
            )
            
            static let separatorInsets: UIEdgeInsets = .init(
                top: 0,
                left: 16,
                bottom: 0,
                right: 16
            )
        }
        
        enum Table {
            static let rowHeight: CGFloat = 56
        }
        
        enum Fonts {
            static let name: UIFont = .systemFont(ofSize: 22, weight: .semibold)
            static let email: UIFont = .systemFont(ofSize: 15, weight: .regular)
            static let delete: UIFont = .systemFont(ofSize: 17, weight: .regular)
        }
        
        enum Button {
            static let leading: CGFloat = 100
            static let trailing: CGFloat = -100
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let navigationTitle = "Профиль"
        static let logout = "Выйти"
        static let deleteAccount = "Удалить аккаунт"
    }
    
    // MARK: - Symbols
    
    private enum Symbols {
        static let avatarPlaceholder = "person.crop.circle"
        static let logoutIcon = "rectangle.portrait.and.arrow.right"
    }
    
    // MARK: - ViewModel
    
    private let viewModel: ProfileUserViewModelProtocol
    
    // MARK: - Props
    
    private var bag = Set<AnyCancellable>()
    
    // MARK: - UI
    
    private lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.alwaysBounceVertical = true
        v.contentInsetAdjustmentBehavior = .automatic
        return v
    }()
    
    private lazy var contentStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.alignment = .center
        v.spacing = Metrics.Spacing.verticalStack
        v.isLayoutMarginsRelativeArrangement = true
        v.directionalLayoutMargins = Metrics.Insets.contentInsets
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
    
    private lazy var nameLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = Metrics.Fonts.name
        return l
    }()
    
    private lazy var emailLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.font = Metrics.Fonts.email
        return l
    }()
    
    private lazy var tableContainer = UIView()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.isScrollEnabled = false
        tv.separatorInset = Metrics.Insets.separatorInsets
        tv.rowHeight = Metrics.Table.rowHeight
        tv.dataSource = self
        tv.delegate   = self
        tv.register(ProfileRowCell.self)
        tv.tableFooterView = UIView()
        return tv
    }()
    
    private lazy var logoutButton: BrandedButton = {
        BrandedButton(
            style: .logout(icon: Symbols.logoutIcon),
            title: Texts.logout
        )
    }()
    
    private lazy var logoutContainer = UIView()
    
    private lazy var deleteAccountButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle(Texts.deleteAccount, for: .normal)
        b.setTitleColor(.systemRed, for: .normal)
        b.titleLabel?.font = Metrics.Fonts.delete
        return b
    }()
    
    private lazy var actionsStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = Metrics.Spacing.actionsStack
        v.alignment = .fill
        return v
    }()
    
    // MARK: - Init
    
    init(viewModel: ProfileUserViewModelProtocol) {
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
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(title: Texts.navigationTitle)
        applyUser()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeightIfNeeded()
    }
}

// MARK: - Setup

private extension ProfileUserViewController {
    func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    func setupHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        contentStack.addArrangedSubviews(
            avatarView,
            nameLabel,
            emailLabel,
            tableContainer,
            actionsStack
        )
        
        actionsStack.addArrangedSubviews(
            logoutContainer,
            deleteAccountButton
        )
        
        logoutContainer.addSubview(logoutButton)
        
        tableContainer.addSubview(tableView)
    }
    
    func setupLayout() {
        prepareForAutoLayout()
        setupScrollConstraints()
        setupContentConstraints()
        setupWidthConstraints()
        setupTableConstraints()
        setupLogoutConstraints()
    }
    
    func setupActions() {
        logoutButton.onTap(self, action: #selector(logoutTapped))
        deleteAccountButton.onTap(self, action: #selector(deleteAccountTapped))
    }
    
    func applyUser() {
        
        if let data = viewModel.loadAvatarData(),
           let image = UIImage(data: data) {
            avatarView.image = image
            avatarView.contentMode = .scaleAspectFill
            avatarView.clipsToBounds = true
            avatarView.layer.cornerRadius = Metrics.Avatar.size / 2
        } else {
            avatarView.image = UIImage(systemName: Symbols.avatarPlaceholder)
            avatarView.contentMode = .scaleAspectFit
            avatarView.clipsToBounds = false
            avatarView.layer.cornerRadius = 0
        }
    }
    
    private func bindViewModel() {
        viewModel.userNamePublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.nameLabel.text = $0 }
            .store(in: &bag)

        viewModel.userEmailPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.emailLabel.text = $0 }
            .store(in: &bag)
    }
}

// MARK: - Layout

private extension ProfileUserViewController {
    func prepareForAutoLayout() {
        [scrollView,
         contentStack,
         nameLabel,
         emailLabel,
         tableContainer,
         tableView,
         actionsStack,
         logoutContainer,
         logoutButton].forEach {
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
        [nameLabel, emailLabel, tableContainer, actionsStack].forEach {
            $0.widthAnchor.constraint(
                equalTo: contentStack.layoutMarginsGuide.widthAnchor
            ).isActive = true
        }
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
    
    func setupLogoutConstraints() {
        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(
                equalTo: logoutContainer.topAnchor
            ),
            logoutButton.leadingAnchor.constraint(
                equalTo: logoutContainer.leadingAnchor,
                constant: Metrics.Button.leading
            ),
            logoutButton.trailingAnchor.constraint(
                equalTo: logoutContainer.trailingAnchor,
                constant: Metrics.Button.trailing
            ),
            logoutButton.bottomAnchor.constraint(
                equalTo: logoutContainer.bottomAnchor
            )
        ])
    }
    
    func updateTableHeightIfNeeded() {
        let desired = CGFloat(viewModel.rowsCount) * tableView.rowHeight
        + Metrics.Spacing.tableTopPadding
        tableView.constraints
            .filter { $0.firstAttribute == .height }
            .forEach { $0.isActive = false }
        tableView.heightAnchor.constraint(equalToConstant: desired).isActive = true
    }
}

// MARK: - Actions

private extension ProfileUserViewController {
    @objc func logoutTapped() {
        let alert = UIAlertController.makeConfirmation(.logout, onConfirm: { [weak self] in
            guard let self else { return }
            Task {
                do {
                    try await self.viewModel.logout()
                    self.onLogoutTap?()
                } catch {
                    self.present(UIAlertController.makeError(error), animated: true)
                }
            }
        })
        present(alert, animated: true)
    }
    
    @objc func deleteAccountTapped() {
        let alert = UIAlertController.makeConfirmation(.deleteAccount, onConfirm: { [weak self] in
            guard let self else { return }
            Task {
                do {
                    try await self.viewModel.deleteAccount()
                    self.onDeleteAccountTap?()
                } catch {
                    self.present(UIAlertController.makeError(error), animated: true)
                }
            }
        })
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ProfileUserViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.rowsCount
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let row = viewModel.row(at: indexPath.row) else { return UITableViewCell() }
        let cell: ProfileRowCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(title: row.title, systemImage: row.systemImage)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ProfileUserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = viewModel.row(at: indexPath.row) else { return }
        switch row {
        case .editProfile:
            onEditProfileTap?()
        case .orders:
            onOrdersTap?()
        case .about:
            onAboutTap?()
        case .contact:
            onContactTap?()
        case .privacy:
            onPrivacyTap?()
        }
    }
}
