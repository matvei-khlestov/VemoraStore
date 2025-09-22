//
//  DeliveryDetailsSheetViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.09.2025.
//

import UIKit
import Combine

final class DeliveryDetailsSheetViewController: UIViewController {
    
    // MARK: - Public
    
    var onSave: ((String) -> Void)?
    
    // MARK: - ViewModel
    
    private let viewModel: DeliveryDetailsViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI
    
    private let typeBoxContentStack = UIStackView()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 28, weight: .bold)
        return label
    }()
    
    private lazy var noFlatTitle: UILabel = {
        let label = UILabel()
        label.text = "Без квартиры"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private lazy var noFlatSubtitle: UILabel = {
        let label = UILabel()
        label.text = "Частный дом, БЦ, склад или магазин"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var checkboxButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.brightPurple.cgColor
        button.backgroundColor = .clear
        button.configuration = .plain()
        button.configuration?.imagePadding = 0
        return button
    }()
    
    private lazy var aptField: PaddedField = {
        let textField = PaddedField(kind: .apt, placeholder: "Квартира *")
        textField.delegate = self
        textField.addTarget(self, action: #selector(aptChanged(_:)), for: .editingChanged)
        return textField
    }()
    
    private lazy var entranceField: PaddedField = {
        let textField = PaddedField(kind: .entrance, placeholder: "Подъезд")
        textField.delegate = self
        textField.addTarget(self, action: #selector(entranceChanged(_:)), for: .editingChanged)
        return textField
    }()
    
    private lazy var floorField: PaddedField = {
        let textField = PaddedField(kind: .floor, placeholder: "Этаж")
        textField.delegate = self
        textField.addTarget(self, action: #selector(floorChanged(_:)), for: .editingChanged)
        return textField
    }()
    
    private lazy var intercomField: PaddedField = {
        let textField = PaddedField(kind: .intercom, placeholder: "Код домофона")
        textField.delegate = self
        textField.addTarget(self, action: #selector(intercomChanged(_:)), for: .editingChanged)
        return textField
    }()
    
    private lazy var saveButton: UIButton = {
        return BrandedButton.make(.primary, title: "Сохранить адрес")
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .tertiaryLabel
        return button
    }()
    
    private lazy var typeBox: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 18
        
        let verticalStack = UIStackView(arrangedSubviews: [noFlatTitle, noFlatSubtitle])
        verticalStack.axis = .vertical
        verticalStack.spacing = 2
        
        typeBoxContentStack.axis = .horizontal
        typeBoxContentStack.alignment = .center
        typeBoxContentStack.distribution = .fill
        typeBoxContentStack.spacing = 12
        typeBoxContentStack.isLayoutMarginsRelativeArrangement = true
        typeBoxContentStack.layoutMargins = .init(top: 14, left: 14, bottom: 14, right: 14)
        typeBoxContentStack.addArrangedSubview(verticalStack)
        typeBoxContentStack.addArrangedSubview(checkboxButton)
        
        containerView.addSubview(typeBoxContentStack)
        return containerView
    }()
    
    private lazy var fieldsStack: UIStackView = {
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.spacing = 12
        
        let firstRowStack = UIStackView(arrangedSubviews: [aptField, entranceField])
        firstRowStack.axis = .horizontal
        firstRowStack.spacing = 12
        firstRowStack.distribution = .fillEqually
        
        let secondRowStack = UIStackView(arrangedSubviews: [floorField, intercomField])
        secondRowStack.axis = .horizontal
        secondRowStack.spacing = 12
        secondRowStack.distribution = .fillEqually
        
        verticalStack.addArrangedSubview(firstRowStack)
        verticalStack.addArrangedSubview(secondRowStack)
        return verticalStack
    }()
    
    private lazy var container: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 18
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 16, left: 16, bottom: 24, right: 16)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(typeBox)
        stackView.addArrangedSubview(fieldsStack)
        stackView.addArrangedSubview(saveButton)
        return stackView
    }()
    
    // MARK: - Init
    
    init(viewModel: DeliveryDetailsViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        configureSheet()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func configureSheet() {
        modalPresentationStyle = .pageSheet
        isModalInPresentation = true
        if let sheet = sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.medium()]
                sheet.selectedDetentIdentifier = .medium
            } else {
                sheet.detents = [.medium()]
                sheet.selectedDetentIdentifier = .medium
            }
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        buildUI()
        applyBaseAddress()
        wireActions()
        bindViewModel()
    }
    
    // MARK: - UI build
    
    private func buildUI() {
        view.addSubview(closeButton)
        view.addSubview(container)
        setupConstraints()
        view.bringSubviewToFront(closeButton)
    }
    
    // MARK: - Bindings
    
    private func bindViewModel() {
        // Отображение/скрытие полей при переключении чекбокса
        viewModel.noFlat
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isNoFlat in
                self?.updateCheckboxUI(isSelected: isNoFlat)
                self?.fieldsStack.isHidden = isNoFlat
                if let sheet = self?.sheetPresentationController, #available(iOS 16.0, *) {
                    sheet.animateChanges { }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions & State
    
    private func wireActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        checkboxButton.addTarget(self, action: #selector(toggleNoFlat), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    
    private func applyBaseAddress() {
        titleLabel.text = viewModel.baseAddress
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func toggleNoFlat() {
        viewModel.toggleNoFlat()
    }
    
    @objc private func saveTapped() {
        // Валидация квартиры при необходимости
        if !viewModel.validateAptIfNeeded() {
            aptField.setState(.error)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            return
        } else {
            aptField.setState(.normal)
        }
        
        let formatted = viewModel.buildFinalAddress()
        onSave?(formatted)
    }
    
    // MARK: - Text Change Handlers
    
    @objc private func aptChanged(_ sender: UITextField) {
        viewModel.apt.send(sender.text ?? "")
    }
    @objc private func entranceChanged(_ sender: UITextField) {
        viewModel.entrance.send(sender.text ?? "")
    }
    @objc private func floorChanged(_ sender: UITextField) {
        viewModel.floor.send(sender.text ?? "")
    }
    @objc private func intercomChanged(_ sender: UITextField) {
        viewModel.intercom.send(sender.text ?? "")
    }
    
    // MARK: - Helpers
    
    private func updateCheckboxUI(isSelected: Bool) {
        if isSelected {
            checkboxButton.backgroundColor = .brightPurple
            checkboxButton.setImage(
                UIImage(
                    systemName: "checkmark",
                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
                ),
                for: .normal
            )
            checkboxButton.tintColor = .white
        } else {
            checkboxButton.tintColor = .clear
            checkboxButton.backgroundColor = .clear
            checkboxButton.setImage(nil, for: .normal)
        }
    }
}

// MARK: - UITextFieldDelegate

extension DeliveryDetailsSheetViewController: UITextFieldDelegate {
    /// Разрешаем только цифры (и удаление) для всех полей, кроме intercomField, где разрешены цифры и буквы
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        // Allow deletion
        if string.isEmpty { return true }
        let allowed: CharacterSet
        if textField == intercomField {
            allowed = CharacterSet.alphanumerics
        } else {
            allowed = CharacterSet.decimalDigits
        }
        return string.unicodeScalars.allSatisfy { allowed.contains($0) }
    }
}

// MARK: - Constraints

private extension DeliveryDetailsSheetViewController {
    func setupConstraints() {
        // Close button
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        // Container
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Type box content stack pinned to edges
        typeBoxContentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            typeBoxContentStack.topAnchor.constraint(equalTo: typeBox.topAnchor),
            typeBoxContentStack.leadingAnchor.constraint(equalTo: typeBox.leadingAnchor),
            typeBoxContentStack.trailingAnchor.constraint(equalTo: typeBox.trailingAnchor),
            typeBoxContentStack.bottomAnchor.constraint(equalTo: typeBox.bottomAnchor)
        ])
        
        // Fixed sizes
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkboxButton.widthAnchor.constraint(equalToConstant: 22),
            checkboxButton.heightAnchor.constraint(equalToConstant: 22)
        ])
        
        // Text fields heights
        [aptField, entranceField, floorField, intercomField].forEach { tf in
            tf.translatesAutoresizingMaskIntoConstraints = false
            tf.heightAnchor.constraint(equalToConstant: 52).isActive = true
        }
    }
}
