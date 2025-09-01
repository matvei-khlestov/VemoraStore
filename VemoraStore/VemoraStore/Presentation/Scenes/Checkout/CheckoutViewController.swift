//
//  CheckoutViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit
import Combine
import FactoryKit
import CoreLocation

final class CheckoutViewController: UIViewController {
    
    // MARK: - Public callbacks
    
    var onPickOnMap: (() -> Void)?
    var onFinished: (() -> Void)?
    
    // MARK: - Deps
    
    private let viewModel: CheckoutViewModel
    
    // MARK: - UI
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .systemBackground
        tv.dataSource = self
        tv.delegate = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()
    
    private let deliveryControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Самовывоз", "Доставка"])
        sc.tintColor = .systemPurple
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let addressTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Адрес доставки"
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = .secondaryLabel
        return l
    }()
    
    private let addressValueButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Выбрать на карте", for: .normal)
        b.contentHorizontalAlignment = .leading
        return b
    }()
    
    private let noteTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Комментарий к заказу"
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = .secondaryLabel
        return l
    }()
    
    private let noteTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 15)
        tv.backgroundColor = .secondarySystemBackground
        tv.layer.cornerRadius = 10
        tv.textContainerInset = .init(top: 8, left: 12, bottom: 8, right: 12)
        return tv
    }()
    
    private let totalLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.text = "Итого: 0 ₽"
        return l
    }()
    
    private lazy var placeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Оформить заказ", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        b.backgroundColor = .systemGreen
        b.tintColor = .white
        b.layer.cornerRadius = 12
        b.addTarget(self, action: #selector(placeTapped), for: .touchUpInside)
        return b
    }()
    
    private let bottomBar = UIStackView()
    
    // MARK: - State
    
    private var items: [CartItemEntity] = []
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(viewModel: CheckoutViewModel = Container.shared.checkoutViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        setupActions()
        bindViewModel()
        configureInitialState()
    }
}

// MARK: - Layout & Bindings

private extension CheckoutViewController {
    func setupLayout() {
        // Верхняя форма
        let formStack = UIStackView(arrangedSubviews: [
            deliveryControl,
            addressTitleLabel,
            addressValueButton,
            noteTitleLabel,
            noteTextView
        ])
        formStack.axis = .vertical
        formStack.spacing = 8
        formStack.isLayoutMarginsRelativeArrangement = true
        formStack.layoutMargins = .init(top: 8, left: 16, bottom: 8, right: 16)
        
        // Контейнер для формы + таблицы
        let container = UIStackView(arrangedSubviews: [formStack, tableView])
        container.axis = .vertical
        container.spacing = 8
        container.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(container)
        
        // Нижняя панель
        bottomBar.axis = .horizontal
        bottomBar.alignment = .center
        bottomBar.spacing = 12
        bottomBar.distribution = .fill
        bottomBar.layoutMargins = .init(top: 8, left: 16, bottom: 8, right: 16)
        bottomBar.isLayoutMarginsRelativeArrangement = true
        bottomBar.addArrangedSubview(totalLabel)
        bottomBar.addArrangedSubview(placeButton)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(bottomBar)
        
        // Автолэйаут
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            container.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),
            
            bottomBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            noteTextView.heightAnchor.constraint(equalToConstant: 90)
        ])
        
        // Кнопка — фикс ширина
        placeButton.setContentHuggingPriority(.required, for: .horizontal)
        placeButton.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    func setupActions() {
        addressValueButton.addTarget(self, action: #selector(addressTapped), for: .touchUpInside)
        deliveryControl.addTarget(self, action: #selector(deliveryChanged), for: .valueChanged)
        noteTextView.delegate = self
    }
    
    func bindViewModel() {
        // Товары
        viewModel.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.items = items
                self?.tableView.reloadData()
            }
            .store(in: &bag)
        
        // Сумма
        viewModel.totalPublisher
            .map { "Итого: \(Int($0)) ₽" }
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: totalLabel)
            .store(in: &bag)
        
        // Доступность кнопки «Оформить заказ»
        viewModel.isPlaceOrderEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enabled in
                self?.placeButton.isEnabled = enabled
                self?.placeButton.alpha = enabled ? 1.0 : 0.5
            }
            .store(in: &bag)
        
        // Отображение адреса
        viewModel.$address
            .receive(on: DispatchQueue.main)
            .sink { [weak self] addr in
                guard let self else { return }
                if let addr {
                    self.addressValueButton.setTitle(addr.formatted, for: .normal)
                } else {
                    self.addressValueButton.setTitle("Выбрать на карте", for: .normal)
                }
            }
            .store(in: &bag)
    }
    
    func configureInitialState() {
        deliveryControl.selectedSegmentIndex = 0 // pickup по умолчанию
        addressTitleLabel.isHidden = true
        addressValueButton.isHidden = true
        noteTextView.text = ""
    }
    
    func toggleAddressVisibility(for method: CheckoutViewModel.DeliveryMethod) {
        let isDelivery = (method == .delivery)
        addressTitleLabel.isHidden = !isDelivery
        addressValueButton.isHidden = !isDelivery
    }
}

// MARK: - Actions

private extension CheckoutViewController {
    @objc func deliveryChanged() {
        let method: CheckoutViewModel.DeliveryMethod = (deliveryControl.selectedSegmentIndex == 0) ? .pickup : .delivery
        viewModel.setDeliveryMethod(method)
        toggleAddressVisibility(for: method)
    }
    
    @objc func addressTapped() {
        onPickOnMap?()
    }
    
    @objc func placeTapped() {
        placeButton.isEnabled = false
        viewModel.placeOrder()
        // Простая задержка-имитация завершения (в VM уже есть delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            self?.placeButton.isEnabled = true
            self?.onFinished?()
        }
    }
}

// MARK: - UITableViewDataSource

extension CheckoutViewController: UITableViewDataSource {
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

extension CheckoutViewController: UITableViewDelegate { }

// MARK: - UITextViewDelegate

extension CheckoutViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.note = textView.text
    }
}

// MARK: - Address helper (optional formatting)

extension Address {
    /// Красивое представление адреса для UI
    var formatted: String {
        let trimmedStreet = street.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let trimmedCity   = city.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return [trimmedStreet, trimmedCity]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    /// Установить/обновить координаты
    mutating func setCoordinate(_ coord: CLLocationCoordinate2D?) {
        self.lat = coord?.latitude
        self.lon = coord?.longitude
    }
}



