//
//  OrdersViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 18.09.2025.
//

import UIKit

final class OrdersViewController: UIViewController {
    
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
        return "\(Texts.sectionHeaderPrefix) \(order.id)"
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell: OrderItemCell = tableView.dequeueReusableCell(for: indexPath)
        
        if let order = viewModel.order(at: indexPath.section),
           let item = viewModel.item(at: indexPath) {
            cell.configure(item: item, order: order)
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
