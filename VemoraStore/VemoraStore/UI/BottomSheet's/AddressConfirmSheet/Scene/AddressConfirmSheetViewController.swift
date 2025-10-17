//
//  AddressConfirmSheetViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.09.2025.
//

import UIKit
import MapKit

/// Контроллер `AddressConfirmSheetViewController`
/// для экрана ввода и подтверждения адреса доставки.
///
/// Основные задачи:
/// - ввод и поиск адреса через `UITextField` с автодополнением (MapKit);
/// - отображение списка подсказок `MKLocalSearchCompletion` в таблице;
/// - подтверждение выбранного адреса и переход к деталям доставки;
/// - управление состоянием шита (compact/search);
/// - уведомление родителя о выборе адреса, окончании редактирования и полном адресе.
///
/// Взаимодействует с:
/// - `AddressConfirmSheetViewModelProtocol` — управление поиском и разрешением адресов;
/// - `DeliveryDetailsViewModelProtocol` — фабрика для второго шита с деталями адреса;
/// - `AddressSuggestionCell` — ячейка для отображения подсказок.
///
/// Особенности:
/// - поддерживает детенты compact/large с плавной анимацией;
/// - аккуратно переключает UI при поиске и выборе адреса;
/// - реализует обратные связи (`onAddressPicked`, `onFullAddressComposed`, `onEditingChanged`).

final class AddressConfirmSheetViewController: UIViewController {
    
    // MARK: - Public Callbacks
    
    /// Колбэк выбора адреса: (отформатированный адрес, координата)
    var onAddressPicked: ((String, CLLocationCoordinate2D) -> Void)?
    
    /// Возвращает в родителя полностью собранный адрес из второго шита
    var onFullAddressComposed: ((String) -> Void)?
    
    /// Сообщает родителю, что поле адреса вошло/вышло из режима редактирования
    var onEditingChanged: ((Bool) -> Void)?
    
    // MARK: - Dependencies
    
    private let viewModel: AddressConfirmSheetViewModelProtocol
    private let makeDeliveryDetailsVM: (String) -> DeliveryDetailsViewModelProtocol
    
    // MARK: - Constants
    
    private enum Metrics {
        enum Sheet {
            static let compactDetentID = UISheetPresentationController.Detent.Identifier(
                "addressConfirm.compact260"
            )
        }
        
        enum Insets {
            static let verticalTop: CGFloat = 12
            static let stackMargins: NSDirectionalEdgeInsets = .init(
                top: 16,
                leading: 16,
                bottom: 20,
                trailing: 16
            )
        }
        
        enum Spacing {
            static let verticalStack: CGFloat = 16
            static let tableTop: CGFloat = 8
        }
        
        enum Fonts {
            static let title: UIFont = .systemFont(ofSize: 17, weight: .semibold)
        }
        
        enum Sizes {
            static let textFieldHeight: CGFloat = 48
            static let compactDetentHeight: CGFloat = 260
        }
        
        enum Corners {
            static let sheet: CGFloat = 16
        }
    }
    
    private enum Texts {
        static let title = "Введите адрес"
        static let addressPlaceholder = "Адрес"
        static let `continue` = "Продолжить"
    }
    
    // MARK: - State
    
    private enum Mode { case compact, search }
    private var mode: Mode = .compact {
        didSet {
            updateModeUI(animated: true)
        }
    }
    
    /// Отрисовываем из VM сюда, чтобы не ломать текущую таблицу
    private var completions: [MKLocalSearchCompletion] = []
    
    // MARK: - Public Props
    
    var searchRegion: MKCoordinateRegion? {
        didSet {
            viewModel.region = searchRegion
        }
    }
    
    var address: String? {
        didSet {
            addressField.text = address
        }
    }
    
    // MARK: - UI
    
    private lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.text = Texts.title
        v.textAlignment = .center
        v.font = Metrics.Fonts.title
        return v
    }()
    
    private lazy var addressField: UITextField = {
        let tf = UITextField()
        tf.placeholder = Texts.addressPlaceholder
        tf.borderStyle = .roundedRect
        tf.isUserInteractionEnabled = true
        tf.returnKeyType = .done
        tf.clearButtonMode = .whileEditing
        tf.heightAnchor.constraint(equalToConstant: Metrics.Sizes.textFieldHeight).isActive = true
        tf.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        tf.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        tf.delegate = self
        return tf
    }()
    
    private lazy var continueButton: BrandedButton = {
        BrandedButton(
            style: .primary,
            title: Texts.continue
        )
    }()
    
    private lazy var suggestionsTable: UITableView = {
        let v = UITableView(frame: .zero, style: .plain)
        v.isHidden = true
        v.keyboardDismissMode = .onDrag
        v.tableFooterView = UIView()
        v.dataSource = self
        v.delegate = self
        v.register(AddressSuggestionCell.self)
        return v
    }()
    
    private lazy var stack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.alignment = .fill
        v.spacing = Metrics.Spacing.verticalStack
        v.isLayoutMarginsRelativeArrangement = true
        v.directionalLayoutMargins = Metrics.Insets.stackMargins
        return v
    }()
    
    // MARK: - Init
    
    init(
        viewModel: AddressConfirmSheetViewModelProtocol,
        makeDeliveryDetailsVM: @escaping (String) -> DeliveryDetailsViewModelProtocol
    ) {
        self.viewModel = viewModel
        self.makeDeliveryDetailsVM = makeDeliveryDetailsVM
        super.init(nibName: nil, bundle: nil)
        setupSheet()
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
        updateModeUI(animated: false)
        viewModel.region = searchRegion
    }
}

// MARK: - Setup

private extension AddressConfirmSheetViewController {
    func setupSheet() {
        modalPresentationStyle = .pageSheet
        isModalInPresentation = true
        guard let sheet = sheetPresentationController else { return }
        sheet.delegate = self
        if #available(iOS 16.0, *) {
            let compact = UISheetPresentationController.Detent.custom(
                identifier: Metrics.Sheet.compactDetentID
            ) { _ in Metrics.Sizes.compactDetentHeight }
            sheet.detents = [compact, .large()]
            sheet.selectedDetentIdentifier = Metrics.Sheet.compactDetentID
            sheet.largestUndimmedDetentIdentifier = Metrics.Sheet.compactDetentID
        } else {
            sheet.detents = [.medium(), .large()]
            sheet.selectedDetentIdentifier = .medium
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        sheet.prefersGrabberVisible = true
        sheet.preferredCornerRadius = Metrics.Corners.sheet
    }
    
    func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    func setupHierarchy() {
        stack.addArrangedSubviews(
            titleLabel,
            addressField,
            continueButton
        )
        view.addSubviews(
            stack,
            suggestionsTable
        )
    }
    
    func setupLayout() {
        [stack, suggestionsTable].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: Metrics.Insets.verticalTop
            ),
            stack.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            stack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            )
        ])
        
        NSLayoutConstraint.activate([
            suggestionsTable.topAnchor.constraint(
                equalTo: stack.bottomAnchor,
                constant: Metrics.Spacing.tableTop
            ),
            suggestionsTable.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            suggestionsTable.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            suggestionsTable.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            )
        ])
    }
    
    func setupActions() {
        continueButton.onTap(self, action: #selector(continueTapped))
    }
    
    func bindViewModel() {
        viewModel.onResultsChanged = { [weak self] results in
            guard let self else { return }
            self.completions = results
            self.suggestionsTable.reloadData()
        }
        viewModel.onResolvedAddress = { [weak self] display, coordinate in
            self?.applySelection(addressText: display, coordinate: coordinate)
        }
    }
}

// MARK: - Mode switching

private extension AddressConfirmSheetViewController {
    func updateModeUI(animated: Bool) {
        let updates = {
            switch self.mode {
            case .compact:
                self.suggestionsTable.isHidden = true
                self.continueButton.isHidden = false
                self.addressField.resignFirstResponder()
                if let sheet = self.sheetPresentationController {
                    if #available(iOS 16.0, *) {
                        sheet.animateChanges {
                            sheet.selectedDetentIdentifier = Metrics.Sheet.compactDetentID
                        }
                    } else {
                        sheet.selectedDetentIdentifier = .medium
                    }
                }
            case .search:
                self.suggestionsTable.isHidden = false
                self.continueButton.isHidden = true
                self.addressField.becomeFirstResponder()
                if let sheet = self.sheetPresentationController {
                    if #available(iOS 16.0, *) {
                        sheet.animateChanges {
                            sheet.selectedDetentIdentifier = .large
                        }
                    } else {
                        sheet.selectedDetentIdentifier = .large
                    }
                }
            }
        }
        animated ? UIView.animate(withDuration: 0.2, animations: updates) : updates()
    }
}

// MARK: - Actions

private extension AddressConfirmSheetViewController {
    @objc func continueTapped() {
        let base = addressField.text ?? ""
        let detailsViewModel = makeDeliveryDetailsVM(base)
        let details = DeliveryDetailsSheetViewController(viewModel: detailsViewModel)
        details.onSave = { [weak self] full in
            guard let self else { return }
            self.onFullAddressComposed?(full)
            self.presentingViewController?.dismiss(animated: true)
        }
        present(details, animated: true)
    }
    
    @objc func editingDidBegin() {
        onEditingChanged?(true)
        mode = .search
    }
    
    @objc func editingChanged() {
        viewModel.updateQuery(addressField.text ?? "")
    }
    
    func applySelection(addressText: String, coordinate: CLLocationCoordinate2D) {
        addressField.text = addressText
        onAddressPicked?(addressText, coordinate)
        onEditingChanged?(false)
        view.endEditing(true)
        mode = .compact
    }
}

// MARK: - UITextFieldDelegate

extension AddressConfirmSheetViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let query = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if query.isEmpty {
            onEditingChanged?(false)
            mode = .compact
            return true
        }
        viewModel.resolveFreeText(query)
        return true
    }
}

// MARK: - UITableViewDataSource

extension AddressConfirmSheetViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        completions.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = completions[indexPath.row]
        let cell: AddressSuggestionCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(with: model)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension AddressConfirmSheetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.resolve(completion: completions[indexPath.row])
    }
}

// MARK: - UISheetPresentationControllerDelegate

extension AddressConfirmSheetViewController: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheet: UISheetPresentationController) {
        if #available(iOS 16.0, *) {
            if sheet.selectedDetentIdentifier == .large {
                if mode != .search {
                    mode = .search
                }
            } else if sheet.selectedDetentIdentifier == Metrics.Sheet.compactDetentID {
                if mode != .compact {
                    mode = .compact
                }
            }
        } else {
            if sheet.selectedDetentIdentifier == .large {
                if mode != .search {
                    mode = .search
                }
            } else if sheet.selectedDetentIdentifier == .medium {
                if mode != .compact {
                    mode = .compact
                }
            }
        }
    }
}
