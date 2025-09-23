//
//  AddressConfirmSheetViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.09.2025.
//

import UIKit
import MapKit

final class AddressConfirmSheetViewController: UIViewController {
    
    // MARK: - Detents IDs
    private let compactDetentID = UISheetPresentationController.Detent.Identifier("addressConfirm.compact260")
    
    // MARK: - ViewModel
    private let viewModel: AddressConfirmSheetViewModelProtocol
    private let makeDeliveryDetailsVM: (String) -> DeliveryDetailsViewModelProtocol
    
    // MARK: - Init
    init(viewModel: AddressConfirmSheetViewModelProtocol, makeDeliveryDetailsVM: @escaping (String) -> DeliveryDetailsViewModelProtocol) {
        self.viewModel = viewModel
        self.makeDeliveryDetailsVM = makeDeliveryDetailsVM
        super.init(nibName: nil, bundle: nil)
        configureSheet()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public API
    var searchRegion: MKCoordinateRegion? {
        didSet { viewModel.region = searchRegion }
    }
    
    /// Колбэк выбора адреса: (отформатированный адрес, координата)
    var onAddressPicked: ((String, CLLocationCoordinate2D) -> Void)?
    /// Возвращает в родителя полностью собранный адрес из второго шита
    var onFullAddressComposed: ((String) -> Void)?
    /// сообщает родителю, что поле адреса вошло/вышло из режима редактирования
    var onEditingChanged: ((Bool) -> Void)?
    
    var address: String? {
        didSet { addressField.text = address }
    }
    
    // MARK: - UI
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Введите адрес"
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        return l
    }()
    
    private lazy var addressField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Адрес"
        tf.borderStyle = .roundedRect
        tf.isUserInteractionEnabled = true
        tf.returnKeyType = .done
        tf.clearButtonMode = .whileEditing
        tf.heightAnchor.constraint(equalToConstant: 48).isActive = true
        tf.addTarget(self, action: #selector(editingDidBegin), for: .editingDidBegin)
        tf.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        tf.delegate = self
        return tf
    }()
    
    private let continueButton = BrandedButton(style: .primary, title: "Продолжить")
    
    private lazy var suggestionsTable: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.isHidden = true
        tv.keyboardDismissMode = .onDrag
        tv.tableFooterView = UIView()
        tv.dataSource = self
        tv.delegate = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()
    
    private let stack = UIStackView()
    
    // MARK: - State
    private enum Mode { case compact, search }
    private var mode: Mode = .compact {
        didSet { updateModeUI(animated: true) }
    }
    /// Отрисовываем из VM сюда, чтобы не ломать текущую таблицу
    private var completions: [MKLocalSearchCompletion] = []
    
    
    private func configureSheet() {
        modalPresentationStyle = .pageSheet
        isModalInPresentation = true
        if let sheet = sheetPresentationController {
            sheet.delegate = self
            if #available(iOS 16.0, *) {
                let compact = UISheetPresentationController.Detent.custom(identifier: compactDetentID) { _ in 260 }
                sheet.detents = [compact, .large()]
                sheet.selectedDetentIdentifier = compactDetentID
                sheet.largestUndimmedDetentIdentifier = compactDetentID
            } else {
                sheet.detents = [.medium(), .large()]
                sheet.selectedDetentIdentifier = .medium
                sheet.largestUndimmedDetentIdentifier = .medium
            }
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        bindViewModel()
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        updateModeUI(animated: false)
        // если регион уже передали до viewDidLoad
        viewModel.region = searchRegion
    }
    
    private func bindViewModel() {
        viewModel.onResultsChanged = { [weak self] results in
            guard let self else { return }
            self.completions = results
            self.suggestionsTable.reloadData()
        }
        viewModel.onResolvedAddress = { [weak self] display, coordinate in
            self?.applySelection(addressText: display, coordinate: coordinate)
        }
    }
    
    private func setupLayout() {
        stack.axis = .vertical
        stack.spacing = 16
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(top: 16, left: 16, bottom: 20, right: 16)
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(addressField)
        stack.addArrangedSubview(continueButton)
        
        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        view.addSubview(suggestionsTable)
        suggestionsTable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            suggestionsTable.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 8),
            suggestionsTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            suggestionsTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            suggestionsTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Mode switching
    private func updateModeUI(animated: Bool) {
        let updates = {
            switch self.mode {
            case .compact:
                self.suggestionsTable.isHidden = true
                self.continueButton.isHidden = false
                self.addressField.resignFirstResponder()
                if let sheet = self.sheetPresentationController {
                    if #available(iOS 16.0, *) {
                        sheet.animateChanges { sheet.selectedDetentIdentifier = self.compactDetentID }
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
                        sheet.animateChanges { sheet.selectedDetentIdentifier = .large }
                    } else {
                        sheet.selectedDetentIdentifier = .large
                    }
                }
            }
        }
        if animated { UIView.animate(withDuration: 0.2, animations: updates) } else { updates() }
    }
    
    // MARK: - Actions
    @objc private func continueTapped() {
        let base = addressField.text ?? ""
        let detailsViewModel = makeDeliveryDetailsVM(base)
        let details = DeliveryDetailsSheetViewController(viewModel: detailsViewModel)
        details.onSave = { [weak self] (full: String) in
            guard let self else { return }
            self.onFullAddressComposed?(full)
            self.presentingViewController?.dismiss(animated: true)
        }
        present(details, animated: true)
    }
    
    @objc private func editingDidBegin() {
        onEditingChanged?(true)
        mode = .search
    }
    
    @objc private func editingChanged() {
        viewModel.updateQuery(addressField.text ?? "")
    }
    
    private func applySelection(addressText: String, coordinate: CLLocationCoordinate2D) {
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

// MARK: - UITableViewDataSource/Delegate
extension AddressConfirmSheetViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { completions.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let c = completions[indexPath.row]
        var conf = cell.defaultContentConfiguration()
        conf.text = c.title
        conf.textProperties.font = .systemFont(ofSize: 16, weight: .semibold)
        conf.secondaryText = c.subtitle
        conf.secondaryTextProperties.color = .secondaryLabel
        cell.contentConfiguration = conf
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.resolve(completion: completions[indexPath.row])
    }
}

// MARK: - UISheetPresentationControllerDelegate
extension AddressConfirmSheetViewController: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        if #available(iOS 16.0, *) {
            if sheetPresentationController.selectedDetentIdentifier == .large {
                if mode != .search { mode = .search }
            } else if sheetPresentationController.selectedDetentIdentifier == compactDetentID {
                if mode != .compact { mode = .compact }
            }
        } else {
            if sheetPresentationController.selectedDetentIdentifier == .large {
                if mode != .search { mode = .search }
            } else if sheetPresentationController.selectedDetentIdentifier == .medium {
                if mode != .compact { mode = .compact }
            }
        }
    }
}
