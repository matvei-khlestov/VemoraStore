//
//  CartViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit
import Combine

/// Контроллер `CartViewController` для экрана корзины.
///
/// Отвечает за:
/// - отображение списка товаров и состояния пустой корзины (`UITableView`);
/// - взаимодействие с `CartViewModelProtocol` (биндинг данных, форматирование цен);
/// - обработку действий пользователя: изменение количества, удаление позиции,
///   полная очистка и переход к оформлению заказа;
/// - показ и обновление вспомогательных вью (пустое состояние, «плавающая» кнопка);
/// - обработку событий делегатов `UITableViewDataSource`/`UITableViewDelegate` и
///   делегата ячейки `CartCellDelegate`;
/// - маршрутизацию результата через колбэки `onCheckout`, `onSelectProductId`.
///
/// Контроллер не содержит бизнес-логики — она в ViewModel и сервисах.
/// Особенности: анимированные апдейты строк без лишних `reloadData`,
/// корректные инкрусты таблицы под кнопку, планирование напоминаний
/// о брошенной корзине делегируется во ViewModel.

final class CartViewController: UIViewController {
    
    // MARK: - Public Callbacks
    
    var onCheckout: (() -> Void)?
    var onSelectProductId: ((String) -> Void)?
    
    // MARK: - Dependencies
    
    private let viewModel: CartViewModelProtocol
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 16
            static let verticalTop: CGFloat = 20
            static let verticalBottom: CGFloat = 0
            static let emptyStateHorizontal: CGFloat = 24
        }
        
        enum Spacing {
            static let buttonBottom: CGFloat = 16
        }
        
        enum Layout {
            enum BottomOverlay {
                static let topPadding: CGFloat = 16
                static let buttonHeight: CGFloat = 52
                static let bottomPadding: CGFloat = 16
            }
        }
        
        enum Table {
            static let rowHeightEstimate: CGFloat = 140
        }
        
        enum Fonts {
            static let emptyState: UIFont = .systemFont(ofSize: 16, weight: .regular)
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let navigationTitle = "Корзина"
        static let emptyState = "Ваша корзина пуста"
        static let checkoutButtonTitle = "Оформить заказ"
        static let clearButtonTitle = "Очистить"
        static let deleteAction = "Удалить"
    }
    
    // MARK: - UI
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.backgroundColor = .white
        view.separatorStyle = .singleLine
        view.dataSource = self
        view.delegate = self
        view.estimatedRowHeight = Metrics.Table.rowHeightEstimate
        view.rowHeight = UITableView.automaticDimension
        view.register(CartCell.self)
        return view
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = Metrics.Fonts.emptyState
        label.numberOfLines = 0
        label.text = Texts.emptyState
        label.isHidden = true
        return label
    }()
    
    private lazy var checkoutButton: BrandedButton = {
        let button = BrandedButton(
            style: .primaryWithShadow,
            title: Texts.checkoutButtonTitle
        )
        return button
    }()
    
    // MARK: - State
    
    private var items: [CartItem] = [] {
        didSet { updateEmptyState() }
    }
    private var bag = Set<AnyCancellable>()
    /// Чтобы не делать reloadData во время анимированных апдейтов строк
    private var isPerformingRowUpdate = false
    
    // MARK: - Initialization
    
    init(viewModel: CartViewModelProtocol) {
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
        updateEmptyState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(title: Texts.navigationTitle)
        updateClearButtonState()        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.scheduleCartReminderForLeavingScreen()
    }
}

// MARK: - Setup

private extension CartViewController {
    func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    func setupHierarchy() {
        view.addSubviews(
            tableView,
            emptyLabel,
            checkoutButton
        )
    }
    
    func setupLayout() {
        prepareForAutoLayout()
        setupTableInsets()
        setupTableConstraints()
        setupEmptyStateConstraints()
        setupCheckoutButtonConstraints()
        view.bringSubviewToFront(checkoutButton)
    }
    
    func setupActions() {
        checkoutButton.onTap(self, action: #selector(checkoutTapped))
    }
    
    func bindViewModel() {
        viewModel.cartItemsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cartItems in
                guard let self else { return }
                self.items = cartItems
                if !self.isPerformingRowUpdate {
                    self.tableView.reloadData()
                }
                self.updateClearButtonState() // 👈 добавляем
            }
            .store(in: &bag)
    }
}

// MARK: - Layout

private extension CartViewController {
    func prepareForAutoLayout() {
        [tableView, emptyLabel, checkoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    /// Инсеты таблицы под «плавающую» кнопку
    func setupTableInsets() {
        let bottomSafePadding =
        Metrics.Layout.BottomOverlay.topPadding
        + Metrics.Layout.BottomOverlay.buttonHeight
        + Metrics.Layout.BottomOverlay.bottomPadding
        tableView.contentInset.bottom = bottomSafePadding
        tableView.verticalScrollIndicatorInsets.bottom = bottomSafePadding
    }
    
    func setupTableConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Metrics.Insets.verticalTop
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),
            tableView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            )
        ])
    }
    
    func setupEmptyStateConstraints() {
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor,
                constant: Metrics.Insets.emptyStateHorizontal
            ),
            emptyLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor,
                constant: -Metrics.Insets.emptyStateHorizontal
            )
        ])
    }
    
    func setupCheckoutButtonConstraints() {
        NSLayoutConstraint.activate([
            checkoutButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Metrics.Insets.horizontal
            ),
            checkoutButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Metrics.Insets.horizontal
            ),
            checkoutButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -Metrics.Spacing.buttonBottom
            )
        ])
    }
}

// MARK: - Empty state

private extension CartViewController {
    func updateEmptyState() {
        let isEmpty = items.isEmpty
        emptyLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        checkoutButton.isHidden = isEmpty
    }
    
    func updateClearButtonState() {
        navigationItem.rightBarButtonItem = items.isEmpty
        ? nil
        : .brandedClear(
            title: Texts.clearButtonTitle,
            target: self,
            action: #selector(clearCartTapped)
        )
    }
}

// MARK: - Row Mutations

private extension CartViewController {
    /// Единая точка удаления строки — синхронизация с VM и анимированный апдейт
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
        
        // 3) Сообщим VM удалить по productId (надёжнее, чем по индексу)
        viewModel.removeItem(with: removed.productId)
    }
}

// MARK: - Actions

private extension CartViewController {
    @objc func checkoutTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        onCheckout?()
    }
    
    @objc func clearCartTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let alert = UIAlertController.makeConfirmation(.clearCart) { [weak self] in
            self?.viewModel.clearCart()
        }
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CartCell = tableView.dequeueReusableCell(for: indexPath)
        let item = items[indexPath.row]
        let priceText = viewModel.formattedPrice(item.lineTotal)
        cell.configure(with: item, priceText: priceText)
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let productId = items[indexPath.row].productId
        onSelectProductId?(productId)
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(
            style: .destructive,
            title: Texts.deleteAction
        ) { [weak self] _, _, completion in
            guard let self else { completion(false); return }
            self.deleteRow(at: indexPath)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

// MARK: - CartCellDelegate

extension CartViewController: CartCellDelegate {
    func cartCell(_ cell: CartCell, didChangeQuantity newValue: Int) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let item = items[indexPath.row]
        viewModel.setQuantity(for: item.productId, quantity: newValue)
        items[indexPath.row].quantity = max(1, newValue)
    }
}
