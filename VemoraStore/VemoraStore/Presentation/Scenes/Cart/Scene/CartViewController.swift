//
//  CartViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit
import Combine
import FactoryKit

final class CartViewController: UIViewController {

    // MARK: - Public Callbacks
    var onCheckout: (() -> Void)?
    var onSelectProduct: ((Product) -> Void)?

    // MARK: - Deps
    private let viewModel: CartViewModel

    // MARK: - UI
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .systemGroupedBackground
        tv.separatorStyle = .singleLine
        tv.dataSource = self
        tv.delegate = self
        tv.estimatedRowHeight = 140
        tv.rowHeight = UITableView.automaticDimension
        tv.register(CartCell.self, forCellReuseIdentifier: CartCell.reuseId)
        return tv
    }()

    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.numberOfLines = 0
        l.text = "Ваша корзина пуста"
        l.isHidden = true
        return l
    }()

    private lazy var checkoutButton: UIButton = {
        let button = BrandedButton.make(.primaryWithShadow, title: "Оформить заказ")
        button.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - State
    private var items: [CartItem] = [] {
        didSet { updateEmptyState() }
    }
    private var bag = Set<AnyCancellable>()
    /// Флаг, чтобы не делать reloadData во время анимированных апдейтов строк
    private var isPerformingRowUpdate = false

    // MARK: - Init
    init(viewModel: CartViewModel = CartViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Корзина"
        view.backgroundColor = .systemBackground
        setupLayout()
        bindViewModel()
        reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

// MARK: - Private
private extension CartViewController {
    func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(checkoutButton)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        checkoutButton.translatesAutoresizingMaskIntoConstraints = false

        let bottomSafePadding: CGFloat = 16 + 52 + 16
        tableView.contentInset.bottom = bottomSafePadding
        tableView.verticalScrollIndicatorInsets.bottom = bottomSafePadding

        NSLayoutConstraint.activate([
            // Таблица
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // Пустой стейт
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

            // Кнопка Checkout
            checkoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            checkoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            checkoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        // Кнопка поверх таблицы
        view.bringSubviewToFront(checkoutButton)
    }

    func bindViewModel() {
        viewModel.$cartItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cartItems in
                guard let self else { return }
                self.items = cartItems
                if !self.isPerformingRowUpdate {
                    self.tableView.reloadData()
                }
            }
            .store(in: &bag)
    }

    func reload() {
        // Пока моки; замените на загрузку из сервиса корзины
        viewModel.loadMocks()
        updateEmptyState()
    }

    func updateEmptyState() {
        emptyLabel.isHidden = !items.isEmpty
        tableView.isHidden = items.isEmpty
        checkoutButton.isHidden = items.isEmpty
    }

    /// Единая точка удаления строки — поддерживает синхронизацию с VM и анимированный апдейт
    func deleteRow(at indexPath: IndexPath) {
        guard items.indices.contains(indexPath.row) else { return }

        // 1) Локально обновим snapshot
        let removed = items.remove(at: indexPath.row)

        // 2) Анимируем удаление строки
        isPerformingRowUpdate = true
        tableView.performBatchUpdates({
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }, completion: { [weak self] _ in
            guard let self else { return }
            self.isPerformingRowUpdate = false
            self.updateEmptyState()
        })

        // 3) Сообщим VM удалить ту же позицию по id (чтобы избежать расхождений индексов)
        viewModel.removeItem(with: removed.id)
    }

    // MARK: - Actions
    @objc func checkoutTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        onCheckout?()
    }
}

// MARK: - UITableViewDataSource
extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CartCell.reuseId,
                                                       for: indexPath) as? CartCell else {
            return UITableViewCell()
        }
        let item = items[indexPath.row]
        cell.configure(with: item.product, quantity: item.quantity)
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onSelectProduct?(items[indexPath.row].product)
    }

    // Свайп-удаление
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            guard let self else { completion(false); return }
            self.deleteRow(at: indexPath)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

// MARK: - CartCellDelegate
extension CartViewController: CartCellDelegate {
    /// Вызывается из ячейки при изменении количества (после нажатия − или +)
    func cartCell(_ cell: CartCell, didChangeQuantity newValue: Int) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let item = items[indexPath.row]
        viewModel.setQuantity(for: item.id, quantity: newValue)
        // быстро синхронизируем локальный snapshot, чтобы не ждать паблишера
        items[indexPath.row].quantity = max(1, newValue)
    }

    /// Удаление через кнопку в самой ячейке
    func cartCellDidTapDelete(_ cell: CartCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        deleteRow(at: indexPath)
    }
}
