//
//  FavoritesViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit
import Combine

final class FavoritesViewController: UIViewController {
    
    // MARK: - Public Callbacks
    var onSelectProduct: ((String) -> Void)?
    
    // MARK: - Dependencies
    private let viewModel: FavoritesViewModelProtocol
    
    // MARK: - Metrics
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 16
            static let verticalTop: CGFloat = 20
            static let verticalBottom: CGFloat = 0
        }
        enum Spacing { }
        enum Fonts {
            static let emptyState: UIFont = .systemFont(ofSize: 16, weight: .regular)
        }
        enum Table {
            static let rowHeightEstimate: CGFloat = 112
        }
        enum EmptyState {
            static let horizontalPadding: CGFloat = 24
        }
    }
    
    // MARK: - Texts
    private enum Texts {
        static let navigationTitle = "Избранное"
        static let emptyState = "Пока нет избранных товаров"
        static let swipeDelete = "Удалить"
        static let clearButtonTitle = "Очистить"              // 👈 ДОБАВЛЕНО
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
        view.register(FavoritesCell.self)
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
    
    // MARK: - State
    private var items: [FavoriteItem] = [] { didSet { updateEmptyState() } }
    private var bag = Set<AnyCancellable>()
    /// Чтобы не делать reloadData во время анимированных апдейтов строк
    private var isPerformingRowUpdate = false
    
    // MARK: - Initialization
    init(viewModel: FavoritesViewModelProtocol) {
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
        bindViewModel()
        reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(title: Texts.navigationTitle)
        updateClearButtonState()                             
    }
}

// MARK: - Setup
private extension FavoritesViewController {
    func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    func setupHierarchy() {
        view.addSubviews(
            tableView,
            emptyLabel
        )
    }
    
    func setupLayout() {
        prepareForAutoLayout()
        setupTableConstraints()
        setupEmptyStateConstraints()
    }
    
    func bindViewModel() {
        // Избранные элементы
        viewModel.favoriteItemsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self else { return }
                self.items = items
                if !self.isPerformingRowUpdate {
                    self.tableView.reloadData()
                }
                self.updateClearButtonState()
            }
            .store(in: &bag)
        
        // Корзина: обновляем видимые ячейки при изменении состояния
        viewModel.inCartIdsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                for cell in self.tableView.visibleCells {
                    guard let cell = cell as? FavoritesCell,
                          let indexPath = self.tableView.indexPath(for: cell),
                          self.items.indices.contains(indexPath.row) else { continue }
                    let item = self.items[indexPath.row]
                    cell.setInCart(self.viewModel.isInCart(item.productId), animated: true)
                }
            }
            .store(in: &bag)
    }
}

// MARK: - Layout
private extension FavoritesViewController {
    func prepareForAutoLayout() {
        [tableView, emptyLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
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
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -Metrics.Insets.verticalBottom
            )
        ])
    }
    
    func setupEmptyStateConstraints() {
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: view.leadingAnchor,
                constant: Metrics.EmptyState.horizontalPadding
            ),
            emptyLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: view.trailingAnchor,
                constant: -Metrics.EmptyState.horizontalPadding
            )
        ])
    }
}

// MARK: - Data Loading
private extension FavoritesViewController {
    func reload() {
        // никаких моков — состояние приходит из VM
        updateEmptyState()
    }
    
    func updateEmptyState() {
        emptyLabel.isHidden = !items.isEmpty
        tableView.isHidden = items.isEmpty
    }
    
    func updateClearButtonState() {
        navigationItem.rightBarButtonItem = items.isEmpty
        ? nil
        : .brandedClear(
            title: Texts.clearButtonTitle,
            target: self,
            action: #selector(clearFavoritesTapped)
        )
    }
    
    @objc func clearFavoritesTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let alert = UIAlertController.makeConfirmation(.clearFavorites) { [weak self] in
            self?.viewModel.clearFavorites()
        }
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Row Mutations
private extension FavoritesViewController {
    /// Единая точка удаления строки — синхронизация с VM и анимированный апдейт
    func deleteRow(at indexPath: IndexPath) {
        guard items.indices.contains(indexPath.row) else { return }
        
        // 1) Локально обновим snapshot
        let removed = items.remove(at: indexPath.row)
        
        // 2) Анимированно удалим строку
        isPerformingRowUpdate = true
        tableView.performBatchUpdates({
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }, completion: { [weak self] _ in
            guard let self else { return }
            self.isPerformingRowUpdate = false
            self.updateEmptyState()
            self.updateClearButtonState()
        })
        
        // 3) Сообщим VM удалить по productId
        viewModel.removeItem(with: removed.productId)
    }
}

// MARK: - UITableViewDataSource
extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell: FavoritesCell = tableView.dequeueReusableCell(for: indexPath)
        let item = items[indexPath.row]
        let priceText = viewModel.formattedPrice(item.price)
        cell.configure(with: item, isInCart: viewModel.isInCart(item.productId), priceText: priceText)
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let productId = items[indexPath.row].productId
        onSelectProduct?(productId)
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(
            style: .destructive,
            title: Texts.swipeDelete
        ) { [weak self] _, _, completion in
            guard let self else { completion(false); return }
            self.deleteRow(at: indexPath)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

// MARK: - FavoritesCellDelegate
extension FavoritesViewController: FavoritesCellDelegate {
    func favoritesCellDidTapCart(_ cell: FavoritesCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              items.indices.contains(indexPath.row) else { return }
        let item = items[indexPath.row]
        
        // Бизнес-логика через VM
        viewModel.toggleCart(for: item.productId)
        
        // Обновим иконку у той же ячейки без перезагрузки строки
        let newState = viewModel.isInCart(item.productId)
        cell.setInCart(newState, animated: false)
    }
}
