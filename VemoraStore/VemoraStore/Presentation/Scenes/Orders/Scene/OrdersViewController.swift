//
//  OrdersViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 18.09.2025.
//

import UIKit
import Combine

/// Контроллер `OrdersViewController` для экрана истории заказов.
///
/// Отвечает за:
/// - отображение заказов в секциях `UITableView` (по одному заказу на секцию);
/// - биндинг данных с `OrdersViewModelProtocol` через Combine и
///   перезагрузку таблицы по обновлениям;
/// - конфигурацию ячеек `OrderItemCell` и тонкого разделителя последней строки;
/// - формирование заголовков секций с маскировкой идентификатора заказа.
///
/// Взаимодействует с:
/// - `OrdersViewModelProtocol` — источник данных, форматирование цены;
/// - делегатами `UITableViewDataSource`/`UITableViewDelegate`;
/// - обратным колбэком `onBack` для навигации назад.
///
/// Особенности:
/// - компактный «брендовый» заголовок секции (`VMR-XXXX…YYYY`);
/// - отсутствие бизнес-логики: контроллер отвечает только за UI и маршрутизацию.

final class OrdersViewController: UIViewController {
    
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Callbacks
    
    var onBack: (() -> Void)?
    
    // MARK: - VM
    
    private let viewModel: OrdersViewModelProtocol
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Table {
            static let sectionHeaderTopPadding: CGFloat = 20
            static let headerHeight: CGFloat = 28
            static let footerHeight: CGFloat = .leastNormalMagnitude
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let screenTitle = "Мои заказы"
        static let sectionHeaderPrefix = "Заказ"
    }
    
    // MARK: - UI
    
    private lazy var tableView: UITableView = {
        let v = UITableView(frame: .zero, style: .insetGrouped)
        v.backgroundColor = .systemGroupedBackground
        v.dataSource = self
        v.delegate = self
        v.separatorStyle = .none
        v.register(OrderItemCell.self)
        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = Metrics.Table.sectionHeaderTopPadding
        }
        return v
    }()
    
    // MARK: - Init
    
    init(viewModel: OrdersViewModelProtocol) {
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
        setupNavigationBar()
        setupHierarchy()
        setupLayout()
        bindViewModel()
    }
}


// MARK: - Bindings

private extension OrdersViewController {
    func bindViewModel() {
        viewModel.ordersPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &bag)
    }
}

// MARK: - Setup

private extension OrdersViewController {
    func setupAppearance() {
        view.backgroundColor = .systemGroupedBackground
    }
    
    func setupNavigationBar() {
        setupNavigationBarWithNavLeftItem(
            title: Texts.screenTitle,
            action: #selector(backTapped),
            largeTitleDisplayMode: .always,
            prefersLargeTitles: true
        )
    }
    
    func setupHierarchy() {
        view.addSubview(tableView)
    }
    
    func setupLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),
            tableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])
    }
}

// MARK: - Actions

@objc private extension OrdersViewController {
    func backTapped() {
        onBack?()
    }
}

// MARK: - UITableViewDataSource

extension OrdersViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sectionsCount
    }
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModel.rows(in: section)
    }
    
    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        guard let order = viewModel.order(at: section) else { return nil }
        return "\(Texts.sectionHeaderPrefix) \(Self.maskedOrderId(order.id))"
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell: OrderItemCell = tableView.dequeueReusableCell(for: indexPath)
        
        if let order = viewModel.order(at: indexPath.section),
           let item = viewModel.item(at: indexPath) {
            let priceText = viewModel.formattedPrice(item.lineTotal)
            cell.configure(item: item, order: order, priceText: priceText)
            let isLast = indexPath.row == viewModel.rows(in: indexPath.section) - 1
            cell.showsSeparator = !isLast
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension OrdersViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        Metrics.Table.headerHeight
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat {
        Metrics.Table.footerHeight
    }
}

// MARK: - Helpers

private extension OrdersViewController {
    /// Return a compact, brandy masked order id for display.
    /// Example: "VMR-1A2B…9F0E" (first 4 / last 4, uppercase, dashes removed)
    static func maskedOrderId(_ id: String) -> String {
        // normalize: remove dashes and uppercase
        let raw = id.replacingOccurrences(of: "-", with: "").uppercased()
        // ensure we have enough characters — fallback to original id if not
        guard raw.count > 8 else { return id }
        
        // take first 4 and last 4
        let head = raw.prefix(4)
        let tail = raw.suffix(4)
        
        // format with a branded prefix
        return "VMR-\(head)…\(tail)"
    }
}
