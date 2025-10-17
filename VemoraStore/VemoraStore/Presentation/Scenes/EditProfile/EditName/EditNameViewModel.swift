//
//  EditNameViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Foundation
import Combine

/// ViewModel `EditNameViewModel` для экрана редактирования имени пользователя.
///
/// Основные задачи:
/// - Валидация введённого имени с помощью `FormValidatingProtocol`;
/// - Наблюдение и загрузка текущего профиля через `ProfileRepository`;
/// - Обновление имени пользователя с сохранением на сервере;
/// - Управление состоянием кнопки "Сохранить" на основе валидности и изменений.
///
/// Обеспечивает реактивное обновление интерфейса через Combine,
/// синхронизируя текущее состояние формы и ошибки валидации в реальном времени.

final class EditNameViewModel: EditNameViewModelProtocol {
    
    // MARK: - Deps
    
    private let userId: String
    private let validator: FormValidatingProtocol
    private let profileRepository: ProfileRepository
    
    // MARK: - State
    
    @Published private var name: String = ""
    @Published private var _nameError: String? = nil
    
    private var initialName: String = ""
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(
        profileRepository: ProfileRepository,
        userId: String,
        validator: FormValidatingProtocol
    ) {
        self.profileRepository = profileRepository
        self.userId = userId
        self.validator = validator
        
        bindProfile()
    }
    
    // MARK: - Outputs
    
    var currentName: String { name }
    var currentError: String? { _nameError }
    
    var nameError: AnyPublisher<String?, Never> {
        $_nameError.eraseToAnyPublisher()
    }
    
    var namePublisher: AnyPublisher<String, Never> {
        $name.eraseToAnyPublisher()
    }
    
    var isSubmitEnabled: AnyPublisher<Bool, Never> {
        let isValid = $_nameError.map { $0 == nil }
        
        let isChanged = $name
            .map { [weak self] new in
                guard let self else { return false }
                let a = new.trimmingCharacters(in: .whitespacesAndNewlines)
                let b = self.initialName.trimmingCharacters(in: .whitespacesAndNewlines)
                return !a.isEmpty && a != b
            }
        
        return Publishers.CombineLatest(isValid, isChanged)
            .map { $0 && $1 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    // MARK: - Inputs
    
    func setName(_ value: String) {
        name = value
    }
    
    // MARK: - Actions
    
    func submit() async throws {
        guard validator.validate(name, for: .name).isValid else { return }
        
        try await profileRepository.updateName(uid: userId, name: name)
        
        await MainActor.run {
            self.initialName = self.name
        }
    }
    
    private func bindProfile() {
        profileRepository.observeProfile()
            .compactMap { $0 }
            .prefix(1)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                guard let self else { return }
                self.initialName = profile.name
                self.name = profile.name
            }
            .store(in: &bag)
        
        $name
            .removeDuplicates()
            .map { [validator] in validator.validate($0, for: .name).message }
            .assign(to: &$_nameError)
    }
}

// MARK: - BaseEditFieldViewModelProtocol

extension EditNameViewModel: BaseEditFieldViewModelProtocol {
    var currentValue: String { currentName }
    var error: AnyPublisher<String?, Never> { nameError }
    func setValue(_ value: String) { setName(value) }
}
