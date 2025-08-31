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

    // MARK: - Public
    var onCheckout: (() -> Void)?

    // MARK: - Deps
    private let viewModel: CartViewModel

    // MARK: - UI
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .systemBackground
        tv.dataSource = self
        tv.delegate = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()

    private let totalLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.textAlignment = .left
        l.text = "Итого: 0 ₽"
        return l
    }()

    private lazy var checkoutButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Оформить заказ", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        b.backgroundColor = .systemGreen
        b.tintColor = .white
        b.layer.cornerRadius = 12
//        b.contentEdgeInsets = .init(top: 12, left: 16, bottom: 12, right: 16)
        b.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
        return b
    }()

    private let bottomBar = UIStackView()

    // MARK: - State
    private var items: [CartItemEntity] = [] {
        didSet { updateTotal() }
    }
    private var bag = Set<AnyCancellable>()

    // MARK: - Init
    init(viewModel: CartViewModel = Container.shared.cartViewModel()) {
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
}

// MARK: - Private
private extension CartViewController {
    func setupLayout() {
        // таблица
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        // нижняя панель: сумма + кнопка
        bottomBar.axis = .horizontal
        bottomBar.alignment = .center
        bottomBar.distribution = .fill
        bottomBar.spacing = 12
        bottomBar.layoutMargins = .init(top: 8, left: 16, bottom: 8, right: 16)
        bottomBar.isLayoutMarginsRelativeArrangement = true
        bottomBar.addArrangedSubview(totalLabel)
        bottomBar.addArrangedSubview(checkoutButton)

        view.addSubview(bottomBar)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor)
        ])

        // Кнопке фиксированная ширина, чтобы лейбл занимал остальное
        checkoutButton.setContentHuggingPriority(.required, for: .horizontal)
        checkoutButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    func bindViewModel() {
         viewModel.$items
           .receive(on: DispatchQueue.main)
           .sink { [weak self] in
               self?.items = $0
               self?.tableView.reloadData()
           }
           .store(in: &bag)
        
         viewModel.totalPublisher
           .map { "Итого: \($0) ₽" }
           .assign(to: \.text, on: totalLabel)
           .store(in: &bag)
    }

    func reload() {
        // TODO: дерни метод загрузки у VM, если он будет
        // viewModel.reload()
        updateTotal()
    }

    func updateTotal() {
        let total = items.reduce(0.0) { $0 + $1.totalPrice }
        totalLabel.text = "Итого: \(Int(total)) ₽"
    }

    @objc func checkoutTapped() {
        onCheckout?()
    }
}

// MARK: - UITableViewDataSource
extension CartViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var cfg = cell.defaultContentConfiguration()
        cfg.text = item.product.name
        cfg.secondaryText = "x\(item.quantity)  ·  \(Int(item.product.price)) ₽"
        cell.contentConfiguration = cfg
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CartViewController: UITableViewDelegate {
     func tableView(_ tableView: UITableView,
                    trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
     -> UISwipeActionsConfiguration? {
         let remove = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _,_,done in
             let id = self?.items[indexPath.row].id ?? ""
             self?.viewModel.remove(id: id)
             done(true)
         }
         return UISwipeActionsConfiguration(actions: [remove])
     }
}
