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
    
    var onSelectProduct: ((ProductTest) -> Void)?
    
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
            static let emptyState: UIFont = .systemFont(ofSize: 15, weight: .regular)
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
    
    private var items: [ProductTest] = [] { didSet { updateEmptyState() } }
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
        viewModel.favoriteProductsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] products in
                guard let self else { return }
                self.items = products
                if !self.isPerformingRowUpdate {
                    self.tableView.reloadData()
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
            emptyLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            emptyLabel.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
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
        // Пока используем моки. Когда появится API — заменим на реальную загрузку.
        viewModel.loadMocks()
        updateEmptyState()
    }
    
    func updateEmptyState() {
        emptyLabel.isHidden = !items.isEmpty
        tableView.isHidden = items.isEmpty
    }
}

// MARK: - Row Mutations

private extension FavoritesViewController {
    /// Единая точка удаления строки — синхронизация с VM и анимированный апдейт
    func deleteRow(at indexPath: IndexPath) {
        guard items.indices.contains(indexPath.row) else { return }
        
        // 1) Обновим локальный snapshot
        _ = items.remove(at: indexPath.row)
        
        // 2) Анимированно удалим строку
        isPerformingRowUpdate = true
        tableView.performBatchUpdates({
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }, completion: { [weak self] _ in
            guard let self else { return }
            self.isPerformingRowUpdate = false
            self.updateEmptyState()
        })
        
        // 3) Попросим VM удалить тот же элемент по индексу
        viewModel.removeItem(at: indexPath.row)
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
        let product = items[indexPath.row]
        cell.configure(with: product, isInCart: viewModel.isInCart(product.id))
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate

extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onSelectProduct?(items[indexPath.row])
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
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let product = items[indexPath.row]
        
        // Бизнес-логика через VM
        viewModel.toggleCart(for: product.id)
        
        // Обновим иконку у той же ячейки без перезагрузки строки
        let newState = viewModel.isInCart(product.id)
        cell.setInCart(newState, animated: false)
    }
    
    func favoritesCellDidTapDelete(_ cell: FavoritesCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        deleteRow(at: indexPath)
    }
}
