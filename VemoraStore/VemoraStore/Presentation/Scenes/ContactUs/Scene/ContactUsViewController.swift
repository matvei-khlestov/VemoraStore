//
//  ContactUsViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import UIKit
import MessageUI

/// Контроллер `ContactUsViewController` для экрана "Контакты".
///
/// Отвечает за:
/// - отображение контактных данных компании в виде таблицы (`UITableView`);
/// - обработку взаимодействий пользователя — звонок, письмо, открытие адреса в Картах;
/// - копирование данных (email, номер, адрес) в буфер обмена при ошибке или из контекстного меню;
/// - показ системных алертов при невозможности выполнить действие.
///
/// Состав:
/// - использует `ContactRowCell` для строк таблицы;
/// - управляет списком `ContactItem.allCases`;
/// - использует `MFMailComposeViewController` для отправки писем.
///
/// Навигация:
/// - кнопка «Назад» вызывает `onBack` для закрытия экрана.
///
/// Особенности:
/// - поддерживает контекстное меню (копирование);
/// - автоматически добавляет отступ в начале таблицы;
/// - универсальные методы `openPhone`, `composeEmail`, `openURL`
///   обрабатывают успешные и неуспешные сценарии с fallback в `UIPasteboard`.

final class ContactUsViewController: UIViewController {
    
    // MARK: - Callbacks
    
    var onBack: (() -> Void)?
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Sizes {
            static let tableTopHeaderHeight: CGFloat = 20
        }
        enum Fonts {
            static let rowSecondary: UIFont = .systemFont(ofSize: 15, weight: .regular)
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let navigationTitle = "Контакты"
        static let copyActionTitle = "Копировать"
        
        static let emailOpenFailedTitle = "Не удалось открыть почту"
        static let emailCopiedMessagePrefix = "Адрес скопирован в буфер обмена:\n"
        
        static let phoneUnavailableTitle = "Звонок недоступен"
        static let phoneCopiedMessagePrefix = "Номер скопирован в буфер обмена:\n"
        
        static let urlOpenFailedTitle = "Не удалось открыть ссылку"
    }
    
    // MARK: - UI
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .insetGrouped)
        view.dataSource = self
        view.delegate = self
        view.register(ContactRowCell.self)
        return view
    }()
    
    // MARK: - Data
    
    private var items: [ContactItem] = ContactItem.allCases
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupNavigationBar()
        setupHierarchy()
        setupLayout()
        configureTableHeaderSpacer()
    }
}

// MARK: - Setup

private extension ContactUsViewController {
    func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    func setupNavigationBar() {
        setupNavigationBarWithNavLeftItem(
            title: Texts.navigationTitle,
            action: #selector(backTapped)
        )
    }
    
    func setupHierarchy() {
        view.addSubviews(tableView)
    }
    
    func setupLayout() {
        prepareForAutoLayout()
        setupTableConstraints()
    }
    
    func configureTableHeaderSpacer() {
        let spacer = UIView(frame: CGRect(
            x: 0, y: 0, width: 1, height: Metrics.Sizes.tableTopHeaderHeight
        ))
        spacer.backgroundColor = .clear
        tableView.tableHeaderView = spacer
    }
}

// MARK: - Layout

private extension ContactUsViewController {
    func prepareForAutoLayout() {
        [tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupTableConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            tableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])
    }
}

// MARK: - Actions

private extension ContactUsViewController {
    @objc func backTapped() {
        onBack?()
    }
}

// MARK: - UITableViewDataSource

extension ContactUsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell: ContactRowCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(
            title: item.title,
            detail: item.detail,
            systemImage: item.icon,
            secondaryFont: Metrics.Fonts.rowSecondary,
            iconTint: .brightPurple
        )
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ContactUsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handleSelection(for: items[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @available(iOS 13.0, *)
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let item = items[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let copy = UIAction(
                title: Texts.copyActionTitle,
                image: UIImage(systemName: "doc.on.doc")
            ) { _ in
                UIPasteboard.general.string = item.detail
            }
            return UIMenu(title: "", children: [copy])
        }
    }
}

// MARK: - Selection Handling

private extension ContactUsViewController {
    func handleSelection(for item: ContactItem) {
        switch item {
        case .phone:
            openPhone(item.detail.digitsOnly)
            
        case .email:
            composeEmail(to: item.detail)
            
        case .address:
            let query = item.detail.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            openURL(raw: "http://maps.apple.com/?q=\(query)")
        }
    }
}

// MARK: - Interactions (phone/email) + Alerts

extension ContactUsViewController: MFMailComposeViewControllerDelegate {
    func composeEmail(to address: String) {
        if MFMailComposeViewController.canSendMail() {
            let vc = MFMailComposeViewController()
            vc.mailComposeDelegate = self
            vc.setToRecipients([address])
            present(vc, animated: true)
            return
        }
        
        if let url = URL(string: "mailto:\(address)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return
        }
        
        UIPasteboard.general.string = address
        let alert = UIAlertController.makeInfo(
            title: Texts.emailOpenFailedTitle,
            message: Texts.emailCopiedMessagePrefix + address
        )
        present(alert, animated: true)
    }
    
    func openPhone(_ digits: String) {
        guard let url = URL(string: "tel://\(digits)"),
              UIApplication.shared.canOpenURL(url) else {
            UIPasteboard.general.string = digits
            let alert = UIAlertController.makeInfo(
                title: Texts.phoneUnavailableTitle,
                message: Texts.phoneCopiedMessagePrefix + digits
            )
            present(alert, animated: true)
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func openURL(raw: String) {
        guard let url = URL(string: raw),
              UIApplication.shared.canOpenURL(url) else {
            let alert = UIAlertController.makeInfo(
                title: Texts.urlOpenFailedTitle,
                message: raw
            )
            present(alert, animated: true)
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true)
    }
}

// MARK: - Utils

private extension String {
    var digitsOnly: String { filter { $0.isNumber || $0 == "+" } }
}
