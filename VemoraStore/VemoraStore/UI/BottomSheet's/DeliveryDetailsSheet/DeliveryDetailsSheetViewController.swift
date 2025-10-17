//
//  DeliveryDetailsSheetViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.09.2025.
//

import UIKit
import Combine

/// Контроллер `DeliveryDetailsSheetViewController`.
///
/// Отвечает за:
/// - ввод деталей: квартира, подъезд, этаж, домофон;
/// - флаг «Без квартиры» и скрытие полей;
/// - сбор финальной строки адреса и колбэк `onSave`;
/// - валидацию квартиры, подсветку ошибок и haptic;
/// - настройку листа: детент, углы, граббер.
///
/// Состав UI:
/// - заголовок с базовым адресом;
/// - блок «тип адреса» с чекбоксом;
/// - две строки полей `PaddedField`;
/// - кнопка «Сохранить адрес»;
/// - кнопка закрытия.
///
/// Взаимодействует с:
/// - `DeliveryDetailsViewModelProtocol` (Combine bind);
/// - `PaddedField` для ввода с индикацией состояний;
/// - `BrandedButton` для сохранения.
///
/// Особенности:
/// - цифры во всех полях, кроме домофона (буквенно-цифровой);
/// - при `noFlat = true` поля скрываются, лист обновляется;
/// - при невалидной квартире — shake и возврат без сохранения.
///
/// Публичный API:
/// - `onSave(String)` — отдаёт собранный адрес.
///
/// Навигация:
/// - презентуется как `.pageSheet` с детентом `.medium`.

final class DeliveryDetailsSheetViewController: UIViewController {
    
    // MARK: - Public Callback
    
    var onSave: ((String) -> Void)?
    
    // MARK: - Dependencies
    
    private let viewModel: DeliveryDetailsViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Constants
    
    private enum Metrics {
        enum Corners {
            static let sheet: CGFloat = 16
            static let typeBox: CGFloat = 18
            static let checkbox: CGFloat = 6
        }
        
        enum Insets {
            static let container: NSDirectionalEdgeInsets = .init(
                top: 16,
                leading: 16,
                bottom: 24,
                trailing: 16
            )
            static let typeBoxContent: NSDirectionalEdgeInsets = .init(
                top: 14,
                leading: 14,
                bottom: 14,
                trailing: 14
            )
            static let containerTop: CGFloat = 8
            static let closeTop: CGFloat = 10
            static let closeTrailing: CGFloat = 10
        }
        
        enum Spacing {
            static let blocks: CGFloat = 18
            static let rows: CGFloat = 12
            static let inlineElements: CGFloat = 12
            static let typeBoxTitleBlock: CGFloat = 2
        }
        
        enum Fonts {
            static let title: UIFont = .systemFont(ofSize: 28, weight: .bold)
            static let noFlatTitle: UIFont = .systemFont(ofSize: 17, weight: .semibold)
            static let noFlatSubtitle: UIFont = .systemFont(ofSize: 15, weight: .regular)
        }
        
        enum Sizes {
            static let fieldHeight: CGFloat = 52
            static let checkboxSide: CGFloat = 22
            static let checkboxBorderWidth: CGFloat = 2
            static let closeButtonSide: CGFloat = 30
        }
    }
    
    private enum Texts {
        static let titleNoFlat = "Без квартиры"
        static let subtitleNoFlat = "Частный дом, БЦ, склад или магазин"
        
        static let placeholderApt = "Квартира *"
        static let placeholderEntrance = "Подъезд"
        static let placeholderFloor = "Этаж"
        static let placeholderIntercom = "Код домофона"
        
        static let save = "Сохранить адрес"
    }
    
    private enum Symbols {
        static let close = "xmark"
        static let checkmark = "checkmark"
        static let checkmarkConfig = UIImage.SymbolConfiguration(
            pointSize: 10,
            weight: .medium
        )
    }
    
    // MARK: - UI
    
    private lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.textColor = .label
        v.numberOfLines = 0
        v.font = Metrics.Fonts.title
        return v
    }()
    
    private lazy var noFlatTitle: UILabel = {
        let v = UILabel()
        v.text = Texts.titleNoFlat
        v.font = Metrics.Fonts.noFlatTitle
        v.textColor = .label
        return v
    }()
    
    private lazy var noFlatSubtitle: UILabel = {
        let v = UILabel()
        v.text = Texts.subtitleNoFlat
        v.font = Metrics.Fonts.noFlatSubtitle
        v.textColor = .secondaryLabel
        v.numberOfLines = 0
        return v
    }()
    
    private lazy var checkboxButton: UIButton = {
        let b = UIButton(type: .system)
        b.layer.cornerRadius = Metrics.Corners.checkbox
        b.layer.borderWidth = Metrics.Sizes.checkboxBorderWidth
        b.layer.borderColor = UIColor.brightPurple.cgColor
        b.backgroundColor = .clear
        b.configuration = .plain()
        b.configuration?.imagePadding = 0
        return b
    }()
    
    private lazy var aptField: PaddedField = {
        let tf = PaddedField(
            kind: .apt,
            placeholder: Texts.placeholderApt
        )
        tf.delegate = self
        tf.addTarget(
            self,
            action: #selector(aptChanged(_:)),
            for: .editingChanged
        )
        return tf
    }()
    
    private lazy var entranceField: PaddedField = {
        let tf = PaddedField(
            kind: .entrance,
            placeholder: Texts.placeholderEntrance
        )
        tf.delegate = self
        tf.addTarget(
            self,
            action: #selector(entranceChanged(_:)),
            for: .editingChanged
        )
        return tf
    }()
    
    private lazy var floorField: PaddedField = {
        let tf = PaddedField(
            kind: .floor,
            placeholder: Texts.placeholderFloor
        )
        tf.delegate = self
        tf.addTarget(
            self,
            action: #selector(floorChanged(_:)),
            for: .editingChanged
        )
        return tf
    }()
    
    private lazy var intercomField: PaddedField = {
        let tf = PaddedField(
            kind: .intercom,
            placeholder: Texts.placeholderIntercom
        )
        tf.delegate = self
        tf.addTarget(
            self,
            action: #selector(intercomChanged(_:)),
            for: .editingChanged
        )
        return tf
    }()
    
    private lazy var saveButton: BrandedButton = {
        BrandedButton(
            style: .primary,
            title: Texts.save
        )
    }()
    
    private lazy var closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: Symbols.close), for: .normal)
        b.tintColor = .tertiaryLabel
        return b
    }()
    
    // контейнер “тип адреса”
    private lazy var typeBox: UIView = {
        let v = UIView()
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = Metrics.Corners.typeBox
        return v
    }()
    
    // горизонтальный стек для typeBox (подписи + чекбокс)
    private lazy var typeBoxContentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = Metrics.Spacing.inlineElements
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = Metrics.Insets.typeBoxContent
        return stack
    }()
    
    // вертикальный стек для заголовка и подзаголовка внутри typeBox
    private lazy var typeBoxVerticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Metrics.Spacing.typeBoxTitleBlock
        return stack
    }()
    
    // общий вертикальный стек полей (две строки)
    private lazy var fieldsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Metrics.Spacing.rows
        return stack
    }()
    
    // первая строка полей
    private lazy var fieldsRow1Stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Metrics.Spacing.rows
        stack.distribution = .fillEqually
        return stack
    }()
    
    // вторая строка полей
    private lazy var fieldsRow2Stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Metrics.Spacing.rows
        stack.distribution = .fillEqually
        return stack
    }()
    
    // корневой контейнер
    private lazy var container: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.spacing = Metrics.Spacing.blocks
        v.isLayoutMarginsRelativeArrangement = true
        v.directionalLayoutMargins = Metrics.Insets.container
        return v
    }()
    
    // MARK: - Init
    
    init(viewModel: DeliveryDetailsViewModelProtocol) {
        self.viewModel = viewModel
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
        configure()
        bindViewModel()
    }
}

// MARK: - Setup

private extension DeliveryDetailsSheetViewController {
    func setupSheet() {
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
            sheet.preferredCornerRadius = Metrics.Corners.sheet
        }
    }
    
    func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    func setupHierarchy() {
        // typeBox стеки и содержимое
        typeBoxVerticalStack.addArrangedSubviews(
            noFlatTitle,
            noFlatSubtitle
        )
        typeBoxContentStack.addArrangedSubviews(
            typeBoxVerticalStack,
            checkboxButton
        )
        typeBox.addSubview(typeBoxContentStack)
        
        // поля
        fieldsRow1Stack.addArrangedSubviews(
            aptField,
            entranceField
        )
        fieldsRow2Stack.addArrangedSubviews(
            floorField,
            intercomField
        )
        fieldsStack.addArrangedSubviews(
            fieldsRow1Stack,
            fieldsRow2Stack
        )
        
        // корневой контейнер
        container.addArrangedSubviews(
            titleLabel,
            typeBox,
            fieldsStack,
            saveButton
        )
        
        view.addSubviews(closeButton, container)
        view.bringSubviewToFront(closeButton)
    }
    
    func setupLayout() {
        prepareForAutoLayout()
        setupCloseConstraints()
        setupContainerConstraints()
        setupTypeBoxConstraints()
        setupFieldsHeights()
    }
    
    func setupActions() {
        closeButton.onTap(self, action: #selector(closeTapped))
        checkboxButton.onTap(self, action: #selector(toggleNoFlat))
        saveButton.onTap(self, action: #selector(saveTapped))
    }
    
    func configure() {
        titleLabel.text = viewModel.baseAddress
    }
}

// MARK: - Layout

private extension DeliveryDetailsSheetViewController {
    func prepareForAutoLayout() {
        [closeButton,
         container,
         typeBoxContentStack,
         checkboxButton,
         aptField, entranceField, floorField, intercomField].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupCloseConstraints() {
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: Metrics.Insets.closeTop
            ),
            closeButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Metrics.Insets.closeTrailing
            ),
            closeButton.widthAnchor.constraint(
                equalToConstant: Metrics.Sizes.closeButtonSide
            ),
            closeButton.heightAnchor.constraint(
                equalToConstant: Metrics.Sizes.closeButtonSide
            )
        ])
    }
    
    func setupContainerConstraints() {
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: Metrics.Insets.containerTop
            ),
            container.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            container.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            container.bottomAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor
            )
        ])
    }
    
    func setupTypeBoxConstraints() {
        NSLayoutConstraint.activate([
            typeBoxContentStack.topAnchor.constraint(
                equalTo: typeBox.topAnchor
            ),
            typeBoxContentStack.leadingAnchor.constraint(
                equalTo: typeBox.leadingAnchor
            ),
            typeBoxContentStack.trailingAnchor.constraint(
                equalTo: typeBox.trailingAnchor
            ),
            typeBoxContentStack.bottomAnchor.constraint(
                equalTo: typeBox.bottomAnchor
            ),
            checkboxButton.widthAnchor.constraint(
                equalToConstant: Metrics.Sizes.checkboxSide
            ),
            checkboxButton.heightAnchor.constraint(
                equalToConstant: Metrics.Sizes.checkboxSide
            )
        ])
    }
    
    func setupFieldsHeights() {
        [aptField, entranceField, floorField, intercomField].forEach { tf in
            tf.heightAnchor.constraint(equalToConstant: Metrics.Sizes.fieldHeight).isActive = true
        }
    }
}

// MARK: - Binding

private extension DeliveryDetailsSheetViewController {
    func bindViewModel() {
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
}

// MARK: - Actions

private extension DeliveryDetailsSheetViewController {
    @objc func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc func toggleNoFlat() {
        viewModel.toggleNoFlat()
    }
    
    @objc func saveTapped() {
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
    
    @objc func aptChanged(_ sender: UITextField) {
        viewModel.apt.send(sender.text ?? "")
    }
    
    @objc func entranceChanged(_ sender: UITextField) {
        viewModel.entrance.send(sender.text ?? "")
    }
    
    @objc func floorChanged(_ sender: UITextField) {
        viewModel.floor.send(sender.text ?? "")
    }
    
    @objc func intercomChanged(_ sender: UITextField) {
        viewModel.intercom.send(sender.text ?? "")
    }
}

// MARK: - Helpers

private extension DeliveryDetailsSheetViewController {
    func updateCheckboxUI(isSelected: Bool) {
        if isSelected {
            checkboxButton.backgroundColor = .brightPurple
            checkboxButton.setImage(
                UIImage(
                    systemName: Symbols.checkmark,
                    withConfiguration: Symbols.checkmarkConfig
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
        if string.isEmpty { return true } // allow deletion
        let allowed: CharacterSet = (textField == intercomField) ? .alphanumerics : .decimalDigits
        return string.unicodeScalars.allSatisfy {
            allowed.contains($0)
        }
    }
}
