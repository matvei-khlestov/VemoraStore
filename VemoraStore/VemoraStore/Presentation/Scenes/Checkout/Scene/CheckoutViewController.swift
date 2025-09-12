//
//  CheckoutViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit
import Combine
import FactoryKit

final class CheckoutViewController: UIViewController {
    
    // MARK: - Callbacks
    
    var onPickOnMap: (() -> Void)?
    var onFinished: (() -> Void)?
    var onBack: (() -> Void)?
    
    // MARK: - Deps
    
    private let viewModel: CheckoutViewModel
    
    // MARK: - UI
    
    private let deliveryControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Самовывоз", "Доставка"])
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .systemGroupedBackground
        tv.dataSource = self
        tv.delegate = self
        tv.separatorStyle = .none
        // Регистрация кастомных ячеек
        tv.register(PickupAddressCell.self, forCellReuseIdentifier: PickupAddressCell.reuseId)
        tv.register(DeliveryAddressCell.self, forCellReuseIdentifier: DeliveryAddressCell.reuseId)
        tv.register(DeliveryInfoCell.self,   forCellReuseIdentifier: DeliveryInfoCell.reuseId)
        tv.register(PaymentMethodCell.self,  forCellReuseIdentifier: PaymentMethodCell.reuseId)
        tv.register(CheckoutCell.self, forCellReuseIdentifier: CheckoutCell.reuseId)
        tv.register(ChangePhoneCell.self, forCellReuseIdentifier: ChangePhoneCell.reuseId)
        tv.register(OrderCommentCell.self, forCellReuseIdentifier: OrderCommentCell.reuseId)
        if #available(iOS 15.0, *) {
            tv.sectionHeaderTopPadding = 0
        }
        return tv
    }()
    
    // bottom summary
    private let bottomContainer = UIStackView()
    private let summaryRow1 = UIStackView()
    private let summaryRow2 = UIStackView()
    
    private let totalTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Итого"
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.textColor = .label
        return l
    }()
    
    private let totalValueLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .right
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.text = "940 ₽"
        return l
    }()
    
    private let deliveryTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Доставка"
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 15, weight: .regular)
        return l
    }()
    
    private let deliveryValueLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .right
        l.text = "Бесплатно"
        l.textColor = .systemGreen
        l.font = .systemFont(ofSize: 15, weight: .medium)
        return l
    }()
    
    // order button (orange, full-width, with icon, title, and amount on the right)
    private let orderButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = UIColor.systemOrange
        b.layer.cornerRadius = 14
        b.layer.masksToBounds = true
        b.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return b
    }()
    
    private let orderIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "shippingbox"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.setContentHuggingPriority(.required, for: .horizontal)
        return iv
    }()
    private let orderTitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Заказать"
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.textColor = .white
        l.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return l
    }()
    private let orderAmountLabel: UILabel = {
        let l = UILabel()
        l.text = "940 ₽"
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.textColor = .white
        l.textAlignment = .right
        l.setContentHuggingPriority(.required, for: .horizontal)
        return l
    }()
    
    // MARK: - State
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Sections
    private enum Section: Int, CaseIterable {
        case pickupAddress
        case checkout
        case deliveryInfo
        case payment
    }
    
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
        setupNavigationBar()
        setupLayout()
        setupOrderButtonContent()
        setupActions()
        bindViewModel()
    }
}

// MARK: - Setup

private extension CheckoutViewController {
    
    func setupNavigationBar() {
        title = "Оформление заказа"
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = .backItem(
            target: self,
            action: #selector(backTapped),
            tintColor: .brightPurple
        )
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func setupLayout() {
        let topBar = UIView()
        topBar.translatesAutoresizingMaskIntoConstraints = false
        deliveryControl.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(deliveryControl)
        
        NSLayoutConstraint.activate([
            deliveryControl.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 16),
            deliveryControl.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -16),
            deliveryControl.topAnchor.constraint(equalTo: topBar.topAnchor, constant: 12),
            deliveryControl.bottomAnchor.constraint(equalTo: topBar.bottomAnchor, constant: -8)
        ])
        
        view.addSubview(topBar)
        view.addSubview(tableView)
        view.addSubview(bottomContainer)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // bottom container
        bottomContainer.axis = .vertical
        bottomContainer.alignment = .fill
        bottomContainer.distribution = .fill
        bottomContainer.spacing = 12
        bottomContainer.isLayoutMarginsRelativeArrangement = true
        bottomContainer.layoutMargins = .init(top: 12, left: 16, bottom: 16, right: 16)
        bottomContainer.backgroundColor = .systemBackground
        
        // rows inside bottom summary
        summaryRow1.axis = .horizontal
        summaryRow1.alignment = .center
        summaryRow1.distribution = .fill
        summaryRow1.addArrangedSubview(totalTitleLabel)
        summaryRow1.addArrangedSubview(totalValueLabel)
        
        summaryRow2.axis = .horizontal
        summaryRow2.alignment = .center
        summaryRow2.distribution = .fill
        summaryRow2.addArrangedSubview(deliveryTitleLabel)
        summaryRow2.addArrangedSubview(deliveryValueLabel)
        
        bottomContainer.addArrangedSubview(summaryRow1)
        bottomContainer.addArrangedSubview(summaryRow2)
        bottomContainer.addArrangedSubview(orderButton)
        
        NSLayoutConstraint.activate([
            // top bar
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            // table
            tableView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomContainer.topAnchor),
            
            // bottom summary + button
            bottomContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setupOrderButtonContent() {
        let content = UIStackView()
        content.axis = .horizontal
        content.alignment = .center
        content.spacing = 10
        content.translatesAutoresizingMaskIntoConstraints = false
        
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        content.addArrangedSubview(orderIconView)
        content.addArrangedSubview(orderTitleLabel)
        content.addArrangedSubview(spacer)
        content.addArrangedSubview(orderAmountLabel)
        
        orderButton.addSubview(content)
        
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: orderButton.leadingAnchor, constant: 16),
            content.trailingAnchor.constraint(equalTo: orderButton.trailingAnchor, constant: -16),
            content.topAnchor.constraint(equalTo: orderButton.topAnchor, constant: 8),
            content.bottomAnchor.constraint(equalTo: orderButton.bottomAnchor, constant: -8)
        ])
    }
    
    func setupActions() {
        deliveryControl.addTarget(self, action: #selector(deliveryChanged), for: .valueChanged)
        orderButton.addTarget(self, action: #selector(placeTapped), for: .touchUpInside)
    }
    
    func bindViewModel() {
        // Подключи реальные паблишеры суммы/доставки при необходимости
    }
}

// MARK: - Actions

private extension CheckoutViewController {
    @objc func deliveryChanged() {
        tableView.reloadData()
    }
    
    @objc func placeTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        onFinished?()
    }
    
    @objc private func backTapped() {
        onBack?()
    }
}

// MARK: - Table (pickup UI)
extension CheckoutViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { Section.allCases.count }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sec = Section(rawValue: section) else { return 0 }
        switch sec {
        case .pickupAddress:
            // Самовывоз: 1 строка (адрес ПВЗ); Доставка: 3 строки (адрес доставки + телефон + комментарий)
            return (deliveryControl.selectedSegmentIndex == 0) ? 1 : 3
        case .checkout:
            return 2
        case .deliveryInfo, .payment:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .pickupAddress:
            if deliveryControl.selectedSegmentIndex == 0 {
                // Самовывоз: показываем адрес пункта выдачи
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: PickupAddressCell.reuseId,
                    for: indexPath
                ) as! PickupAddressCell
                cell.configure(address: "г. Красногорск, Заводская улица 18к2")
                return cell
            } else {
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: DeliveryAddressCell.reuseId,
                        for: indexPath
                    ) as! DeliveryAddressCell
                    cell.configure(address: nil)
                    return cell
                } else if indexPath.row == 1 {
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: ChangePhoneCell.reuseId,
                        for: indexPath
                    ) as! ChangePhoneCell
                    cell.configure(phone: nil)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(
                        withIdentifier: OrderCommentCell.reuseId,
                        for: indexPath
                    ) as! OrderCommentCell
                    cell.configure(comment: nil)
                    return cell
                }
            }
            
        case .checkout:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CheckoutCell.reuseId,
                for: indexPath
            ) as! CheckoutCell
            let product = Product(
                id: "mock_\(indexPath.row)",
                name: "Vemora Oslo Sofa 3-Seater",
                description: "Mock item for checkout preview",
                price: 940,
                image: URL(string: "https://picsum.photos/seed/checkout\(indexPath.row)/400/300")!,
                categoryId: "sofas",
                brendId: "vemora"
            )
            cell.configure(with: product, quantity: indexPath.row + 1)
            
            let isLastRow = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
            cell.showsSeparator = !isLastRow
            return cell
            
        case .deliveryInfo:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: DeliveryInfoCell.reuseId,
                for: indexPath
            ) as! DeliveryInfoCell
            
            // If segmented control is on pickup (index 0) show "Послезавтра",
            // otherwise (delivery) show "В течение 5 рабочих дней".
            let whenText: String = (deliveryControl.selectedSegmentIndex == 0)
            ? "Послезавтра"
            : "В течение 5 рабочих дней"
            
            cell.configure(when: whenText, cost: "Доставка 0 ₽")
            return cell
            
        case .payment:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PaymentMethodCell.reuseId,
                for: indexPath
            ) as! PaymentMethodCell
            cell.configure(title: "Как оплатить заказ?", method: "При получении")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let sec = Section(rawValue: indexPath.section) else { return }
        switch sec {
        case .pickupAddress:
            if deliveryControl.selectedSegmentIndex == 0 {
                onPickOnMap?()
            } else {
                if indexPath.row == 0 {
                    onPickOnMap?()
                } else if indexPath.row == 1 {
                    let sheet = PhoneInputSheetViewController()
                    sheet.kind = .phone
                    // sheet.initialPhone = viewModel.phone
                    sheet.initialPhone = nil
                    sheet.onSave = { [weak self] phone in
                        guard let self = self else { return }
                        // self.viewModel.phone = phone
                        if let cell = self.tableView.cellForRow(at: indexPath) as? ChangePhoneCell {
                            cell.configure(phone: phone, placeholder: "Указать номер телефона")
                        } else {
                            self.tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                    }
                    present(sheet, animated: true)
                } else {
                    let sheet = PhoneInputSheetViewController()
                    sheet.kind = .comment
                    // sheet.initialComment = viewModel.comment
                    sheet.initialComment = nil
                    sheet.onSave = { [weak self] comment in
                        guard let self = self else { return }
                        // self.viewModel.comment = comment
                        if let cell = self.tableView.cellForRow(at: indexPath) as? OrderCommentCell {
                            cell.configure(comment: comment, placeholder: "Оставить комментарий")
                        } else {
                            self.tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                    }
                    present(sheet, animated: true)
                }
            }
        default:
            break
        }
    }
    
    // MARK: - Compact section spacing
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
}
