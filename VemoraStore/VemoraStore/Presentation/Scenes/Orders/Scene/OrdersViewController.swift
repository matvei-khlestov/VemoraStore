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
    
    // MARK: - UI
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .systemGroupedBackground
        tv.dataSource = self
        tv.delegate = self
        tv.separatorStyle = .none
        tv.register(OrderItemCell.self, forCellReuseIdentifier: OrderItemCell.reuseId)
        if #available(iOS 15.0, *) { tv.sectionHeaderTopPadding = 20 }
        return tv
    }()
    
    // MARK: - Init
    init(viewModel: OrdersViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBarWithNavLeftItem(
            title: "Мои заказы",
            action: #selector(backTapped),
            largeTitleDisplayMode: .always,
            prefersLargeTitles: true
        )
        view.addSubview(tableView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func backTapped() { onBack?() }
}

// MARK: - UITableViewDataSource / Delegate
extension OrdersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sectionsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.rows(in: section)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let order = viewModel.order(at: section) else { return nil }
        return "Заказ \(order.id)"
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: OrderItemCell.reuseId,
            for: indexPath
        ) as? OrderItemCell else {
            return UITableViewCell()
        }
        
        if let order = viewModel.order(at: indexPath.section),
           let item = viewModel.item(at: indexPath) {
            cell.configure(item: item, order: order)
            let isLast = indexPath.row == viewModel.rows(in: indexPath.section) - 1
            cell.showsSeparator = !isLast
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 28 }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { .leastNormalMagnitude }
}
