//
//  FavoritesViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit
import Combine
import FactoryKit

final class FavoritesViewController: UIViewController {
    
    // MARK: - Public
    var onSelectProduct: ((Product) -> Void)?
    
    // MARK: - Deps
    private let viewModel: FavoritesViewModel
    
    // MARK: - UI
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .systemGroupedBackground
        tv.separatorStyle = .singleLine
        tv.dataSource = self
        tv.delegate = self
        tv.estimatedRowHeight = 112
        tv.rowHeight = UITableView.automaticDimension
        tv.register(FavoritesCell.self, forCellReuseIdentifier: FavoritesCell.reuseId)
        return tv
    }()
    
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.numberOfLines = 0
        l.text = "Пока нет избранных товаров"
        l.isHidden = true
        return l
    }()
    
    // MARK: - State
    private var items: [Product] = [] {
        didSet { updateEmptyState() }
    }
    private var bag = Set<AnyCancellable>()
    private var isPerformingRowUpdate = false
    
    // MARK: - Init
    init(viewModel: FavoritesViewModel = Container.shared.favoritesViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Избранное"
        view.backgroundColor = .systemBackground
        setupLayout()
        bindViewModel()
        reload()
    }
}

// MARK: - Private
private extension FavoritesViewController {
    func setupLayout() {
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }
    
    func bindViewModel() {
         viewModel.$favoriteProducts
           .receive(on: DispatchQueue.main)
           .sink { [weak self] products in
               guard let self = self else { return }
               self.items = products
               if !self.isPerformingRowUpdate {
                   self.tableView.reloadData()
               }
           }
           .store(in: &bag)
    }
    
    func reload() {
        // TODO: дернуть метод загрузки, если будет во VM
        // Пока используем моки. Когда появится API — заменим на реальную загрузку.
        viewModel.loadMocks()
        updateEmptyState()
    }
    
    func updateEmptyState() {
        emptyLabel.isHidden = !items.isEmpty
        tableView.isHidden = items.isEmpty
    }
    
    /// Common path for row deletion to keep dataSource and UI in sync (like TaskList sample)
    func deleteRow(at indexPath: IndexPath) {
        guard items.indices.contains(indexPath.row) else { return }
        // 1) Update local data source first
        _ = items.remove(at: indexPath.row)

        // 2) Animate table update
        isPerformingRowUpdate = true
        tableView.performBatchUpdates({
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            self.isPerformingRowUpdate = false
            self.updateEmptyState()
        })

        // 3) Tell the ViewModel to remove the same element by index
        viewModel.removeItem(at: indexPath.row)
    }
}

extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavoritesCell.reuseId, for: indexPath) as? FavoritesCell else {
            return UITableViewCell()
        }
        let product = items[indexPath.row]
        cell.configure(with: product, isInCart: viewModel.isInCart(product.id))
        cell.delegate = self
        return cell
    }
}

extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelectProduct?(items[indexPath.row])
    }

    // Swipe-to-delete
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            guard let self = self else { completion(false); return }
            self.deleteRow(at: indexPath)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

extension FavoritesViewController: FavoritesCellDelegate {
    func favoritesCellDidTapCart(_ cell: FavoritesCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let product = items[indexPath.row]

        // бизнес-логика через VM
        viewModel.toggleCart(for: product.id)

        // обновим иконку у той же ячейки без перерисовки строки
        let newState = viewModel.isInCart(product.id)
        cell.setInCart(newState, animated: false)

        // Если хочешь всё же перезагрузить строку (для синхронизации высот и т.п.):
        // tableView.reloadRows(at: [indexPath], with: .none)
    }
    func favoritesCellDidTapDelete(_ cell: FavoritesCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        deleteRow(at: indexPath)
    }
}
