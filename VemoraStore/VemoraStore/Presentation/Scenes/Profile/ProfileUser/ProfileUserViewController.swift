//
//  ProfileUserViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 17.09.2025.
//

import UIKit

final class ProfileUserViewController: UIViewController {

    // MARK: - Callbacks

    var onEditProfileTap:   (() -> Void)?
    var onOrdersTap:        (() -> Void)?
    var onAboutTap:         (() -> Void)?
    var onContactTap:       (() -> Void)?
    var onPrivacyTap:       (() -> Void)?
    var onLogoutTap:        (() -> Void)?
    var onDeleteAccountTap: (() -> Void)?

    // MARK: - ViewModel

    private let viewModel: ProfileUserViewModelProtocol

    // MARK: - UI

    private lazy var scroll: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentInsetAdjustmentBehavior = .automatic
        v.alwaysBounceVertical = true
        return v
    }()

    private lazy var content: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.alignment = .center
        v.spacing = 20
        v.isLayoutMarginsRelativeArrangement = true
        v.layoutMargins = .init(top: 24, left: 16, bottom: 24, right: 16)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var avatarView: UIImageView = {
        let v = UIImageView(image: UIImage(systemName: "person.crop.circle"))
        v.contentMode = .scaleAspectFit
        v.tintColor = .tertiaryLabel
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalToConstant: 96).isActive = true
        v.heightAnchor.constraint(equalToConstant: 96).isActive = true
        return v
    }()

    private lazy var nameLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 22, weight: .semibold)
        return l
    }()

    private lazy var emailLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.font = .systemFont(ofSize: 15)
        return l
    }()

    private lazy var tableContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.isScrollEnabled = false
        tv.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        tv.rowHeight = 56
        tv.tableFooterView = UIView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private lazy var logoutButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .brightPurple
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        config.title = "Выйти"
        config.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
        config.imagePadding = 10
        config.contentInsets = .init(top: 12, leading: 16, bottom: 12, trailing: 16)

        let b = UIButton(configuration: config, primaryAction: nil)
        b.layer.cornerCurve = .continuous
        b.translatesAutoresizingMaskIntoConstraints = false
        b.heightAnchor.constraint(equalToConstant: 50).isActive = true
        b.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        return b
    }()

    private lazy var deleteAccountButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Удалить аккаунт", for: .normal)
        b.setTitleColor(.systemRed, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.addTarget(self, action: #selector(deleteAccountTapped), for: .touchUpInside)
        return b
    }()

    private lazy var actionsStack: UIStackView = {
        let v = UIStackView(arrangedSubviews: [logoutButton, deleteAccountButton])
        v.axis = .vertical
        v.spacing = 12
        v.alignment = .fill
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Init

    /// Основной init — через VM
    init(viewModel: ProfileUserViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar(title: "Профиль")
        buildLayout()
        setupConstraints()
        wire()
        applyUser()
    }

    // MARK: - Layout

    private func buildLayout() {
        view.addSubview(scroll)
        scroll.addSubview(content)

        content.addArrangedSubview(avatarView)
        content.addArrangedSubview(nameLabel)
        content.addArrangedSubview(emailLabel)

        content.addArrangedSubview(tableContainer)
        tableContainer.addSubview(tableView)

        content.addArrangedSubview(actionsStack)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor)
        ])


        [nameLabel, emailLabel, actionsStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.widthAnchor.constraint(equalTo: content.layoutMarginsGuide.widthAnchor).isActive = true
        }

        tableContainer.widthAnchor.constraint(equalTo: content.layoutMarginsGuide.widthAnchor).isActive = true
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: tableContainer.topAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: tableContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableContainer.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: tableContainer.bottomAnchor)
        ])

        tableView.heightAnchor.constraint(
            equalToConstant: CGFloat(viewModel.rowsCount) * tableView.rowHeight + 8
        ).isActive = true
    }

    // MARK: - Wiring

    private func wire() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    // MARK: - Content

    private func applyUser() {
        nameLabel.text = viewModel.userName
        emailLabel.text = viewModel.userEmail
    }

    // MARK: - Actions

    @objc private func logoutTapped() {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await viewModel.logout()
                onLogoutTap?()
            } catch {
                // TODO: показать алерт/тост
                print("Logout failed:", error)
            }
        }
    }

    @objc private func deleteAccountTapped() {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await viewModel.deleteAccount()
                onDeleteAccountTap?()
            } catch {
                // TODO: показать алерт/тост
                print("Delete account failed:", error)
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension ProfileUserViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.rowsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        guard let row = viewModel.row(at: indexPath.row) else { return cell }

        var conf = cell.defaultContentConfiguration()
        conf.text = row.title
        conf.textProperties.font = .systemFont(ofSize: 17)
        conf.image = UIImage(systemName: row.systemImage)
        conf.imageProperties.tintColor = .secondaryLabel
        cell.contentConfiguration = conf
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ProfileUserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = viewModel.row(at: indexPath.row) else { return }
        switch row {
        case .editProfile: onEditProfileTap?()
        case .orders:      onOrdersTap?()
        case .about:       onAboutTap?()
        case .contact:     onContactTap?()
        case .privacy:     onPrivacyTap?()
        }
    }
}
