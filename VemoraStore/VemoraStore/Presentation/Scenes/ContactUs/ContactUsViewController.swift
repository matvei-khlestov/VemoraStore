//
//  ContactUsViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import UIKit

final class ContactUsViewController: UIViewController {
    
    // MARK: - Callbacks
    
    var onBack: (() -> Void)?
    
    // MARK: - Properties
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset.top = 0
        tableView.verticalScrollIndicatorInsets.top = 0
//        tableView.backgroundColor = .systemBackground
        tableView.tableHeaderView = UIView()
        return tableView
    }()
    
    private var items: [(icon: String, title: String, detail: String, action: () -> Void)] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBarWithNavLeftItem(
            title: "Контакты",
            action:  #selector(backTapped)
        )
        setupItems()
        setupTableView()
    }
    
    // MARK: - Setup
    
    private func setupItems() {
        items = [
            ("phone.fill", "Телефон", "+7 (800) 555-35-35", { }),
            ("envelope.fill", "Email", "support@vemora.ru", { }),
            ("mappin.and.ellipse", "Адрес", "Москва, ул. Примерная, 1", {})
        ]
    }
    
    private func setupTableView() {
        let spacer = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 20))
        spacer.backgroundColor = .clear
        tableView.tableHeaderView = spacer
        view.addSubview(tableView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func backTapped() {
        onBack?()
    }
}

// MARK: - UITableViewDataSource

extension ContactUsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        config.text = item.title
        config.secondaryText = item.detail
        config.secondaryTextProperties.font = .systemFont(ofSize: 15)
        config.image = UIImage(systemName: item.icon)
        config.imageProperties.tintColor = .brightPurple
        cell.contentConfiguration = config
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ContactUsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        items[indexPath.row].action()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        let item = items[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let copy = UIAction(title: "Копировать", image: UIImage(systemName: "doc.on.doc")) { _ in
                UIPasteboard.general.string = item.detail
            }
            return UIMenu(title: "", children: [copy])
        }
    }
}
