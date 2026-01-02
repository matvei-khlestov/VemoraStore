//
//  PhoneInputSheetViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 01.10.2025.
//

import UIKit
import Combine

/// Контроллер `PhoneInputSheetViewController`
/// для экрана ввода номера получателя.
///
/// Основные задачи:
/// - отображение и редактирование телефона через `FormTextField`;
/// - реактивный биндинг с `PhoneInputSheetViewModelProtocol` (Combine);
/// - отображение ошибок валидации в UI;
/// - сохранение введённого номера при нажатии на кнопку.
///
/// Взаимодействует с:
/// - `PhoneInputSheetViewModelProtocol` — хранение состояния и валидация телефона;
/// - `PhoneFormattingProtocol` — форматирование номера в E.164 и человекочитаемом виде;
/// - `BaseInputSheetViewController` — общий базовый UI для шитов.
///
/// Особенности:
/// - при вводе номера автоматически применяется маска `+7`;
/// - валидация выполняется при сохранении;
/// - при ошибке шит остаётся открытым и поле “встряхивается”.

final class PhoneInputSheetViewController: BaseInputSheetViewController {
    
    // MARK: - VM
    
    private let viewModel: PhoneInputSheetViewModelProtocol
    private let phoneFormatter: PhoneFormattingProtocol
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Callback
    
    var onSavePhone: ((String) -> Void)?
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Sizes {
            static let customDetentHeight: CGFloat = 300
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let title = "Укажите номер получателя"
        static let save  = "Сохранить"
    }
    
    // MARK: - UI
    
    private lazy var phoneField = FormTextField(
        kind: .phone,
        phoneFormatter: phoneFormatter
    )
    
    // MARK: - Init
    
    init(
        viewModel: PhoneInputSheetViewModelProtocol,
        phoneFormatter: PhoneFormattingProtocol
    ) {
        self.viewModel = viewModel
        self.phoneFormatter = phoneFormatter
        super.init(
            config: .init(
                title: Texts.title,
                saveTitle: Texts.save,
                customDetentHeight: Metrics.Sizes.customDetentHeight,
                titleAlignment: .center
            )
        )
        modalPresentationStyle = .pageSheet
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attachContentView(phoneField)
        setupActions()
        bindViewModel()
    }
}

// MARK: - Setup

private extension PhoneInputSheetViewController {
    func setupActions() {
        onSave  = { [weak self] in self?.saveTapped() }
        onClose = { [weak self] in self?.dismiss(animated: true) }
        
        phoneField.onTextChanged = { [weak self] e164 in
            self?.viewModel.setPhone(e164)
        }
    }
    
    func bindViewModel() {
        viewModel.phonePublisher
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] e164 in
                guard let self else { return }
                let seed = e164.isEmpty ? "+7" : e164
                self.phoneField.setPhoneE164(seed)
            }
            .store(in: &bag)
        
        viewModel.errorPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] message in
                self?.phoneField.showError(message, force: message != nil)
            }
            .store(in: &bag)
    }
    
    func saveTapped() {
        if viewModel.validate() {
            onSavePhone?(viewModel.phone)
            dismiss(animated: true)
        } else {
            phoneField.shake()
        }
    }
}
