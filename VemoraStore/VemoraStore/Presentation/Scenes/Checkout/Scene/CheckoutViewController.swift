//
//  CheckoutViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit
import Combine

final class CheckoutViewController: UIViewController {
    
    // MARK: - Callbacks
    
    var onPickOnMap: (() -> Void)?
    var onFinished:  (() -> Void)?
    var onBack:      (() -> Void)?
    
    // MARK: - Deps
    
    private let viewModel: CheckoutViewModelProtocol
    
    private let makePhoneSheetVM: (String?) -> PhoneInputSheetViewModelProtocol
    private let makeCommentSheetVM: (String?) -> CommentInputSheetViewModelProtocol
    
    private let phoneFormatter: PhoneFormattingProtocol
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 16
            static let verticalTop: CGFloat = 0
            static let verticalBottom: CGFloat = 0
            
            static let bottomContainer: UIEdgeInsets = .init(
                top: 12,
                left: horizontal,
                bottom: 16,
                right: horizontal
            )
            static let orderButtonContent: UIEdgeInsets = .init(
                top: 8,
                left: 16,
                bottom: 8,
                right: 16
            )
        }
        enum Spacing {
            static let topBarTop: CGFloat = 12
            static let topBarBottom: CGFloat = 8
            static let tableTop: CGFloat = 8
            static let sectionHeader: CGFloat = 12
            static let summaryRows: CGFloat = 12
            static let orderButtonStack: CGFloat = 10
        }
        enum Sizes {
            static let orderButtonHeight: CGFloat = 52
        }
        enum Corners {
            static let orderButton: CGFloat = 14
        }
        enum Fonts {
            static let total: UIFont = .systemFont(ofSize: 17, weight: .semibold)
            static let summaryTitle: UIFont = .systemFont(ofSize: 15, weight: .regular)
            static let summaryValue: UIFont = .systemFont(ofSize: 15, weight: .medium)
            static let orderButton: UIFont = .systemFont(ofSize: 17, weight: .semibold)
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let navTitle = "Оформление заказа"
        static let segmentPickup = "Самовывоз"
        static let segmentDelivery = "Доставка"
        
        static let totalTitle = "Итого"
        static let totalValueExample = "940 ₽"
        
        static let deliveryTitle = "Доставка"
        static let deliveryFree = "Бесплатно"
        static let deliveryWhenPickup = "Послезавтра"
        static let deliveryWhenCourier = "В течение 5 рабочих дней"
        static let cost = "Доставка 0 ₽"
        
        static let orderButtonTitle = "Заказать"
        static let orderAmountExample = "940 ₽"
        
        static let pickupAddressExample = "Москва, Ходынский бульвар 4"
        
        static let paymentTitle = "Как оплатить заказ?"
        static let paymentMethod = "При получении"
        
        static let phonePlaceholder = "Указать номер телефона"
        static let commentPlaceholder = "Оставить комментарий"
    }
    
    // MARK: - Symbols
    
    private enum Symbols {
        static let orderIcon = "shippingbox"
    }
    
    // MARK: - UI
    
    private lazy var topBar: UIView = {
        let v = UIView()
        return v
    }()
    
    private lazy var deliveryControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: [
            Texts.segmentPickup,
            Texts.segmentDelivery
        ])
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .systemGroupedBackground
        tv.dataSource = self
        tv.delegate = self
        tv.separatorStyle = .none
        
        tv.register([
            PickupAddressCell.self,
            DeliveryAddressCell.self,
            DeliveryInfoCell.self,
            PaymentMethodCell.self,
            CheckoutCell.self,
            ChangePhoneCell.self,
            OrderCommentCell.self
        ])
        
        if #available(iOS 15.0, *) {
            tv.sectionHeaderTopPadding = 0
        }
        return tv
    }()
    
    private lazy var bottomContainer: UIStackView = {
        let st = UIStackView()
        st.axis = .vertical
        st.alignment = .fill
        st.distribution = .fill
        st.spacing = Metrics.Spacing.summaryRows
        st.isLayoutMarginsRelativeArrangement = true
        st.layoutMargins = Metrics.Insets.bottomContainer
        st.backgroundColor = .systemBackground
        return st
    }()
    
    private lazy var summaryRow1: UIStackView = {
        let stackView = Self.makeSummaryRow()
        return stackView
    }()
    
    private lazy var summaryRow2: UIStackView = {
        let stackView = Self.makeSummaryRow()
        return stackView
    }()
    
    private lazy var totalTitleLabel: UILabel = {
        let label = Self.makeLabel(
            text: Texts.totalTitle,
            font: Metrics.Fonts.total,
            textColor: .label
        )
        return label
    }()
    
    private lazy var totalValueLabel: UILabel = {
        let label = Self.makeLabel(
            text: Texts.totalValueExample,
            font: Metrics.Fonts.total,
            alignment: .right
        )
        return label
    }()
    
    private lazy var deliveryTitleLabel: UILabel = {
        let label = Self.makeLabel(
            text: Texts.deliveryTitle,
            font: Metrics.Fonts.summaryTitle,
            textColor: .secondaryLabel
        )
        return label
    }()
    
    private lazy var deliveryValueLabel: UILabel = {
        let label = Self.makeLabel(
            text: Texts.deliveryFree,
            font: Metrics.Fonts.summaryValue,
            textColor: .systemGreen,
            alignment: .right
        )
        return label
    }()
    
    
    private lazy var orderButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = .systemOrange
        b.layer.cornerRadius = Metrics.Corners.orderButton
        b.layer.masksToBounds = true
        b.heightAnchor.constraint(equalToConstant: Metrics.Sizes.orderButtonHeight).isActive = true
        return b
    }()
    
    private lazy var orderButtonContentStack: UIStackView = {
        let st = UIStackView()
        st.axis = .horizontal
        st.alignment = .center
        st.spacing = Metrics.Spacing.orderButtonStack
        st.isUserInteractionEnabled = false
        return st
    }()
    
    private lazy var orderIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: Symbols.orderIcon))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.setContentHuggingPriority(.required, for: .horizontal)
        return iv
    }()
    
    private lazy var orderTitleLabel: UILabel = {
        let label = Self.makeLabel(
            text: Texts.orderButtonTitle,
            font: Metrics.Fonts.orderButton,
            textColor: .white,
            hugging: (.defaultLow, .horizontal)
        )
        return label
    }()
    
    private lazy var orderButtonSpacer: UIView = {
        let v = UIView()
        v.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return v
    }()
    
    private lazy var orderAmountLabel: UILabel = {
        let label = Self.makeLabel(
            text: Texts.orderAmountExample,
            font: Metrics.Fonts.orderButton,
            textColor: .white,
            alignment: .right,
            hugging: (.required, .horizontal)
        )
        return label
    }()
    
    // MARK: - State
    
    private var bag = Set<AnyCancellable>()
    private var isPickup: Bool {
        deliveryControl.selectedSegmentIndex == 0
    }
    
    // MARK: - Sections
    
    private enum Section: Int, CaseIterable {
        case pickupAddress
        case checkout
        case deliveryInfo
        case payment
    }
    
    // MARK: - Init
    
    init(
        viewModel: CheckoutViewModelProtocol,
        makePhoneSheetVM: @escaping (String?) -> PhoneInputSheetViewModelProtocol,
        makeCommentSheetVM: @escaping (String?) -> CommentInputSheetViewModelProtocol,
        phoneFormatter: PhoneFormattingProtocol
        
    ) {
        self.viewModel = viewModel
        self.makePhoneSheetVM = makePhoneSheetVM
        self.makeCommentSheetVM = makeCommentSheetVM
        self.phoneFormatter = phoneFormatter
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
        setupActions()
        setupBindViewModel()
    }
}

// MARK: - Setup

private extension CheckoutViewController {
    func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    func setupNavigationBar() {
        setupNavigationBarWithNavLeftItem(
            title: Texts.navTitle,
            action: #selector(backTapped),
            largeTitleDisplayMode: .never,
            prefersLargeTitles: false
        )
    }
    
    func setupHierarchy() {
        view.addSubviews(
            topBar,
            tableView,
            bottomContainer
        )
        topBar.addSubviews(deliveryControl)
        
        summaryRow1.addArrangedSubviews(
            totalTitleLabel,
            totalValueLabel
        )
        summaryRow2.addArrangedSubviews(
            deliveryTitleLabel,
            deliveryValueLabel
        )
        bottomContainer.addArrangedSubviews(
            summaryRow1,
            summaryRow2,
            orderButton
        )
        
        orderButton.addSubviews(
            orderButtonContentStack
        )
        orderButtonContentStack.addArrangedSubviews(
            orderIconView,
            orderTitleLabel,
            orderButtonSpacer,
            orderAmountLabel
        )
    }
    
    func setupLayout() {
        prepareForAutoLayout()
        setupTopBarConstraints()
        setupTableConstraints()
        setupBottomContainerConstraints()
        setupOrderButtonContentConstraints()
    }
    
    func setupActions() {
        deliveryControl.addTarget(self, action: #selector(deliveryChanged), for: .valueChanged)
        orderButton.addTarget(self, action: #selector(placeTapped), for: .touchUpInside)
    }
    
    func setupBindViewModel() {
        bindDeliveryMethod()
        bindDeliveryAddress()
        bindReceiverPhone()
        bindOrderComment()
        bindPlaceOrderEnabled()
    }
}

// MARK: - Bindings

private extension CheckoutViewController {
    func bindDeliveryMethod() {
        viewModel.deliveryMethodPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] method in
                guard let self else { return }
                let index = (method == .pickup) ? 0 : 1
                if self.deliveryControl.selectedSegmentIndex != index {
                    self.deliveryControl.selectedSegmentIndex = index
                }
                self.tableView.reloadSections(
                    IndexSet(integer: Section.pickupAddress.rawValue),
                    with: .automatic
                )
            }
            .store(in: &bag)
    }
    
    func bindDeliveryAddress() {
        viewModel.deliveryAddressStringPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.reloadDeliveryAddressCellIfNeeded()
            }
            .store(in: &bag)
    }
    
    func bindPlaceOrderEnabled() {
        viewModel.isPlaceOrderEnabled
            .receive(on: RunLoop.main)
            .sink { [weak self] enabled in
                self?.orderButton.isEnabled = enabled
                self?.orderButton.alpha = enabled ? 1.0 : 0.5
            }
            .store(in: &bag)
    }
    
    func bindReceiverPhone() {
        viewModel.receiverPhoneDisplayPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.reloadPhoneCellIfNeeded()
            }
            .store(in: &bag)
    }
    
    func bindOrderComment() {
        viewModel.orderCommentPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.reloadCommentCellIfNeeded()
            }
            .store(in: &bag)
    }
}

// MARK: - Layout

private extension CheckoutViewController {
    func prepareForAutoLayout() {
        [topBar,
         deliveryControl,
         tableView,
         bottomContainer,
         orderButtonContentStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupTopBarConstraints() {
        NSLayoutConstraint.activate([
            // deliveryControl в topBar
            deliveryControl.leadingAnchor.constraint(
                equalTo: topBar.leadingAnchor,
                constant: Metrics.Insets.horizontal
            ),
            deliveryControl.trailingAnchor.constraint(
                equalTo: topBar.trailingAnchor,
                constant: -Metrics.Insets.horizontal
            ),
            deliveryControl.topAnchor.constraint(
                equalTo: topBar.topAnchor,
                constant: Metrics.Spacing.topBarTop
            ),
            deliveryControl.bottomAnchor.constraint(
                equalTo: topBar.bottomAnchor,
                constant: -Metrics.Spacing.topBarBottom
            ),
            
            // сам topBar
            topBar.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            topBar.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ),
            topBar.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            )
        ])
    }
    
    func setupTableConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: topBar.bottomAnchor,
                constant: Metrics.Spacing.tableTop
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),
            tableView.bottomAnchor.constraint(
                equalTo: bottomContainer.topAnchor
            )
        ])
    }
    
    func setupBottomContainerConstraints() {
        NSLayoutConstraint.activate([
            bottomContainer.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ),
            bottomContainer.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),
            bottomContainer.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            )
        ])
    }
    
    func setupOrderButtonContentConstraints() {
        NSLayoutConstraint.activate([
            orderButtonContentStack.leadingAnchor.constraint(
                equalTo: orderButton.leadingAnchor,
                constant: Metrics.Insets.orderButtonContent.left
            ),
            orderButtonContentStack.trailingAnchor.constraint(
                equalTo: orderButton.trailingAnchor,
                constant: -Metrics.Insets.orderButtonContent.right
            ),
            orderButtonContentStack.topAnchor.constraint(
                equalTo: orderButton.topAnchor,
                constant: Metrics.Insets.orderButtonContent.top
            ),
            orderButtonContentStack.bottomAnchor.constraint(
                equalTo: orderButton.bottomAnchor,
                constant: -Metrics.Insets.orderButtonContent.bottom
            )
        ])
    }
}

// MARK: - Actions

private extension CheckoutViewController {
    @objc func deliveryChanged() {
        let method: CheckoutViewModel.DeliveryMethod = isPickup ? .pickup : .delivery
        viewModel.setDeliveryMethod(method)
    }
    
    @objc func placeTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        onFinished?()
    }
    
    @objc func backTapped() {
        onBack?()
    }
}

// MARK: - UITableViewDataSource

extension CheckoutViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { Section.allCases.count }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sec = Section(rawValue: section) else { return 0 }
        switch sec {
        case .pickupAddress:
            return isPickup ? 1 : 3
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
            if isPickup {
                let cell: PickupAddressCell = tableView.dequeueReusableCell(for: indexPath)
                cell.configure(address: Texts.pickupAddressExample)
                return cell
            } else {
                switch indexPath.row {
                case 0:
                    let cell: DeliveryAddressCell = tableView.dequeueReusableCell(for: indexPath)
                    cell.configure(address: viewModel.deliveryAddressString)
                    return cell
                case 1:
                    let cell: ChangePhoneCell = tableView.dequeueReusableCell(for: indexPath)
                    cell.configure(
                        phone: viewModel.receiverPhoneDisplay,
                        placeholder: Texts.phonePlaceholder
                    )
                    return cell
                default:
                    let cell: OrderCommentCell = tableView.dequeueReusableCell(for: indexPath)
                    cell.configure(
                        comment: viewModel.orderCommentText,
                        placeholder: Texts.commentPlaceholder
                    )
                    return cell
                }
            }
            
        case .checkout:
            let cell: CheckoutCell = tableView.dequeueReusableCell(for: indexPath)
            let product = Product(
                id: "mock_\(indexPath.row)",
                name: "Vemora Oslo Sofa 3-Seater",
                description: "Mock item for checkout preview",
                nameLower: "vemora oslo sofa 3-seater",
                categoryId: "sofas",
                brandId: "vemora",
                price: 940,
                imageURL: "https://picsum.photos/seed/checkout\(indexPath.row)/400/300",
                isActive: true,
                createdAt: ISO8601DateFormatter().string(from: Date()),
                updatedAt: ISO8601DateFormatter().string(from: Date()),
                keywords: ["mock", "checkout", "диван", "sofa", "vemora"]
            )
            cell.configure(with: product, quantity: indexPath.row + 1)
            let isLastRow = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
            cell.showsSeparator = !isLastRow
            return cell
            
        case .deliveryInfo:
            let cell: DeliveryInfoCell = tableView.dequeueReusableCell(for: indexPath)
            let whenText = isPickup ? Texts.deliveryWhenPickup : Texts.deliveryWhenCourier
            cell.configure(when: whenText, cost: Texts.cost)
            return cell
            
        case .payment:
            let cell: PaymentMethodCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(title: Texts.paymentTitle, method: Texts.paymentMethod)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        Metrics.Spacing.sectionHeader
    }
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        UIView(frame: .zero)
    }
    func tableView(_ tableView: UITableView,
                   heightForFooterInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView,
                   viewForFooterInSection section: Int) -> UIView? {
        UIView(frame: .zero)
    }
}

// MARK: - UITableViewDelegate

extension CheckoutViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = Section(rawValue: indexPath.section) else { return }
        
        switch section {
        case .pickupAddress:
            handlePickupAddressSelection(at: indexPath)
        default:
            break
        }
    }
}

// MARK: - Cell Selection Handling

private extension CheckoutViewController {
    func handlePickupAddressSelection(at indexPath: IndexPath) {
        guard !isPickup else { return }
        
        switch indexPath.row {
        case 0:
            onPickOnMap?()
        case 1:
            presentPhoneInputSheet(at: indexPath)
        default:
            presentCommentInputSheet(at: indexPath)
        }
    }
    
    func presentPhoneInputSheet(at indexPath: IndexPath) {
        let vm = makePhoneSheetVM(viewModel.receiverPhoneE164)
        let sheet = PhoneInputSheetViewController(
            viewModel: vm,
            phoneFormatter: phoneFormatter
        )

        sheet.onSavePhone = { [weak self] phone in
            guard let self else { return }
            self.viewModel.updateReceiverPhone(phone)
        }
        present(sheet, animated: true)
    }
    
    func presentCommentInputSheet(at indexPath: IndexPath) {
        let vm = makeCommentSheetVM(viewModel.orderCommentText)
        let sheet = CommentInputSheetViewController(viewModel: vm)

        sheet.onSaveComment = { [weak self] comment in
            guard let self else { return }
            self.viewModel.updateOrderComment(comment)
        }

        present(sheet, animated: true)
    }
}

// MARK: - Helpers

private extension CheckoutViewController {
    static func makeSummaryRow() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }
    
    static func makeLabel(
        text: String? = nil,
        font: UIFont,
        textColor: UIColor = .label,
        alignment: NSTextAlignment = .natural,
        hugging: (priority: UILayoutPriority,
                  axis: NSLayoutConstraint.Axis)? = nil
    ) -> UILabel {
        let label = UILabel()
        label.text = text
        
        label.font = font
        label.textColor = textColor
        label.textAlignment = alignment
        if let hugging = hugging {
            label.setContentHuggingPriority(hugging.priority, for: hugging.axis)
        }
        return label
    }
}

// MARK: - Reload helpers

private extension CheckoutViewController {
    func reloadCellIfNeeded<Cell: UITableViewCell>(
        row: Int,
        configure visibleCell: (Cell) -> Void
    ) {
        guard !isPickup else { return }
        
        let section = Section.pickupAddress.rawValue
        let indexPath = IndexPath(row: row, section: section)
        
        if let cell: Cell = tableView.visibleCell(at: indexPath) {
            visibleCell(cell)
            tableView.beginUpdates()
            tableView.endUpdates()
        } else if tableView.numberOfSections > section,
                  tableView.numberOfRows(inSection: section) > row {
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func reloadDeliveryAddressCellIfNeeded() {
        reloadCellIfNeeded(row: 0) { (cell: DeliveryAddressCell) in
            cell.configure(address: viewModel.deliveryAddressString)
        }
    }
    
    func reloadPhoneCellIfNeeded() {
        reloadCellIfNeeded(row: 1) { (cell: ChangePhoneCell) in
            cell.configure(
                phone: viewModel.receiverPhoneDisplay,
                placeholder: Texts.phonePlaceholder
            )
        }
    }
    
    func reloadCommentCellIfNeeded() {
        reloadCellIfNeeded(row: 2) { (cell: OrderCommentCell) in
            cell.configure(
                comment: viewModel.orderCommentText,
                placeholder: Texts.commentPlaceholder
            )
        }
    }
}
