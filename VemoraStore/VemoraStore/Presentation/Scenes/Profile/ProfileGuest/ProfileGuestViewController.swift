//
//  ProfileGuestViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import UIKit

final class ProfileGuestViewController: UIViewController {
    
    // MARK: - Callbacks
    
    var onLoginTap: (() -> Void)?
    var onAboutTap: (() -> Void)?
    var onContactTap: (() -> Void)?
    var onPrivacyTap: (() -> Void)?
    
    // MARK: - UI
    
    private lazy var scroll: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var content: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 24, left: 16, bottom: 24, right: 16)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var avatarView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person.crop.circle"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .tertiaryLabel
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 96).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 96).isActive = true
        return imageView
    }()
    
    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Добро пожаловать"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Зарегистрируйтесь или войдите в свой аккаунт, чтобы управлять сервисами Vemora"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    private lazy var authButton: UIButton = {
        let button = BrandedButton.make(.primary, title: "Войти или зарегистрироваться")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.isScrollEnabled = false
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        tableView.rowHeight = 56
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var buttonContainer: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    private lazy var tableContainer: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    // MARK: - Data
    
    private enum Row: Int, CaseIterable {
        case about, contact, privacy
        
        var title: String {
            switch self {
            case .about:   return "О нас"
            case .contact: return "Связаться с нами"
            case .privacy: return "Политика конфиденциальности"
            }
        }
        
        var systemImage: String {
            switch self {
            case .about:   return "storefront.fill"
            case .contact: return "phone.fill"
            case .privacy: return "lock.shield.fill"
            }
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Профиль"
        view.backgroundColor = .systemBackground
        buildLayout()
        setupConstraints()
        wire()
    }
    
    // MARK: - Layout
    
    private func buildLayout() {
        // Скролл, чтобы на маленьких экранах всё помещалось
        view.addSubview(scroll)
        
        // Контент стек
        scroll.addSubview(content)
        
        // контент
        content.addArrangedSubview(avatarView)
        content.addArrangedSubview(welcomeLabel)
        content.addArrangedSubview(subtitleLabel)
        
        // кнопка
        content.addArrangedSubview(buttonContainer)
        buttonContainer.addSubview(authButton)
        
        // таблица
        content.addArrangedSubview(tableContainer)
        tableContainer.addSubview(tableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // scroll to edges
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            // content inside scroll
            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor)
        ])
        
        // button container width and button pin
        buttonContainer.widthAnchor.constraint(equalTo: content.layoutMarginsGuide.widthAnchor).isActive = true
        NSLayoutConstraint.activate([
            authButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
            authButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
            authButton.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor),
            authButton.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor)
        ])
        
        // table container width and table pin
        tableContainer.widthAnchor.constraint(equalTo: content.layoutMarginsGuide.widthAnchor).isActive = true
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: tableContainer.topAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: tableContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableContainer.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: tableContainer.bottomAnchor)
        ])
        
        // фиксированная высота под 3 строки
        tableView.heightAnchor.constraint(equalToConstant: CGFloat(Row.allCases.count) * tableView.rowHeight + 8).isActive = true
    }
    
    // MARK: - Wiring
    
    private func wire() {
        authButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    // MARK: - Actions
    
    @objc private func loginTapped() {
        onLoginTap?()
    }
}

// MARK: - UITableViewDataSource

extension ProfileGuestViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        guard let row = Row(rawValue: indexPath.row) else { return cell }
        
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

extension ProfileGuestViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = Row(rawValue: indexPath.row) else { return }
        switch row {
        case .about:   onAboutTap?()
        case .contact: onContactTap?()
        case .privacy: onPrivacyTap?()
        }
    }
}
