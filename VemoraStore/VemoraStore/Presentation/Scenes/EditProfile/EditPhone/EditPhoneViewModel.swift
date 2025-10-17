//
//  EditPhoneViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Foundation
import Combine

/// ViewModel `EditPhoneViewModel` для экрана редактирования номера телефона.
///
/// Основные задачи:
/// - Валидация введённого номера с помощью `FormValidatingProtocol`;
/// - Наблюдение и загрузка текущего профиля через `ProfileRepository`;
/// - Сохранение номера телефона в профиле и `CheckoutStoringProtocol`;
/// - Управление состоянием кнопки "Сохранить" на основе корректности и изменений.
///
/// Обеспечивает реактивное обновление интерфейса через Combine
/// и синхронизирует актуальный номер телефона между профилем
/// пользователя и данными checkout-модуля.

final class EditPhoneViewModel: EditPhoneViewModelProtocol {
    
    // MARK: - Deps
    
    private let profileRepository: ProfileRepository
    private let validator: FormValidatingProtocol
    private let userId: String
    private var checkoutStorage: CheckoutStoringProtocol
    
    // MARK: - State
    
    @Published private var phone: String = ""
    @Published private var _phoneError: String? = nil
    
    private var initialPhone: String = ""
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(
        profileRepository: ProfileRepository,
        validator: FormValidatingProtocol,
        userId: String,
        checkoutStorage: CheckoutStoringProtocol
    ) {
        self.profileRepository = profileRepository
        self.validator = validator
        self.userId = userId
        self.checkoutStorage = checkoutStorage
        
        bindProfile()
    }
    
    // MARK: - Outputs
    
    var currentPhone: String { phone }
    var currentError: String? { _phoneError }
    
    var phoneError: AnyPublisher<String?, Never> {
        $_phoneError.eraseToAnyPublisher()
    }
    
    var phonePublisher: AnyPublisher<String, Never> {
        $phone.eraseToAnyPublisher()
    }
    
    var isSubmitEnabled: AnyPublisher<Bool, Never> {
        let isValid = $_phoneError.map { $0 == nil }
        
        let isChanged = $phone
            .map { [weak self] new in
                guard let self else { return false }
                let a = new.trimmingCharacters(in: .whitespacesAndNewlines)
                let b = self.initialPhone.trimmingCharacters(in: .whitespacesAndNewlines)
                return !a.isEmpty && a != b
            }
        
        return Publishers.CombineLatest(isValid, isChanged)
            .map { $0 && $1 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    // MARK: - Inputs
    
    func setPhone(_ value: String) { phone = value }
    
    // MARK: - Actions
    
    func submit() async throws {
        guard validator.validate(phone, for: .phone).isValid else { return }
        
        try await profileRepository.updatePhone(uid: userId, phone: phone)
        checkoutStorage.savedReceiverPhoneE164 = phone
        
        await MainActor.run {
            self.initialPhone = self.phone
        }
    }
    
    private func bindProfile() {
        profileRepository.observeProfile()
            .compactMap { $0 }
            .prefix(1)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                guard let self else { return }
                self.initialPhone = profile.phone
                self.phone = profile.phone
                self.checkoutStorage.savedReceiverPhoneE164 = profile.phone
            }
            .store(in: &bag)
        
        $phone
            .removeDuplicates()
            .map { [validator] in validator.validate($0, for: .phone).message }
            .assign(to: &$_phoneError)
    }
}

// MARK: - BaseEditFieldViewModelProtocol

extension EditPhoneViewModel: BaseEditFieldViewModelProtocol {
    var currentValue: String { currentPhone }
    var error: AnyPublisher<String?, Never> { phoneError }
    func setValue(_ value: String) { setPhone(value) }
}
