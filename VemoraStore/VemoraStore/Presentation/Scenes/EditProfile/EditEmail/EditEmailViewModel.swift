//
//  EditEmailViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Foundation
import Combine

/// ViewModel экрана изменения e-mail.
///
/// Отвечает за:
/// - загрузку текущего email из профиля (через `ProfileRepository`);
/// - валидацию email (через `FormValidatingProtocol`);
/// - управление состоянием кнопки "Изменить";
/// - выполнение сценария смены email в два шага:
///   1) изменение email в Auth-провайдере (`AuthServiceProtocol`);
///   2) обновление email в профиле (`ProfileRepository`).
///
/// Особенность UX:
/// - перед выполнением операции требуется пароль текущего пользователя (reauth).
/// - `submit()` инициирует password-challenge и завершает выполнение ошибкой `PasswordChallengeError.passwordRequired`,
///   чтобы UI не завершал сценарий (не делал `onFinish`) до ввода пароля.
/// - после ввода пароля UI вызывает `submit(withPassword:)`.
final class EditEmailViewModel: EditEmailViewModelProtocol {
    
    // MARK: - UI / Flow Errors
    
    /// Служебная ошибка для остановки базового `submit()` и запуска password-challenge UI.
    enum PasswordChallengeError: Error {
        case passwordRequired
    }
    
    // MARK: - Deps
    
    private let profileRepository: ProfileRepository
    private let authService: AuthServiceProtocol
    private let userId: String
    private let validator: FormValidatingProtocol
    
    // MARK: - UI callbacks
    
    /// Вызывается, когда для обновления email требуется текущий пароль.
    /// Контроллер должен показать UI ввода пароля и передать его обратно через `submit(withPassword:)`.
    var onPasswordRequired: (() -> Void)?
    
    // MARK: - State
    
    @Published private var email: String = ""
    @Published private var _emailError: String? = nil
    
    private var initialEmail: String = ""
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(
        profileRepository: ProfileRepository,
        authService: AuthServiceProtocol,
        validator: FormValidatingProtocol,
        userId: String
    ) {
        self.profileRepository = profileRepository
        self.authService = authService
        self.validator = validator
        self.userId = userId
        
        bindProfile()
    }
    
    // MARK: - Outputs
    
    var currentEmail: String { email }
    var currentError: String? { _emailError }
    
    var emailError: AnyPublisher<String?, Never> {
        $_emailError.eraseToAnyPublisher()
    }
    
    var emailPublisher: AnyPublisher<String, Never> {
        $email.eraseToAnyPublisher()
    }
    
    var isSubmitEnabled: AnyPublisher<Bool, Never> {
        let isValid = $_emailError.map { $0 == nil }
        
        let isChanged = $email
            .map { [weak self] new in
                guard let self else { return false }
                let a = new.trimmingCharacters(in: .whitespacesAndNewlines)
                let b = self.initialEmail.trimmingCharacters(in: .whitespacesAndNewlines)
                return !a.isEmpty && a != b
            }
        
        return Publishers.CombineLatest(isValid, isChanged)
            .map { $0 && $1 }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    // MARK: - Inputs
    
    func setEmail(_ value: String) {
        email = value
    }
    
    // MARK: - Actions
    
    /// Первый шаг: инициирует запрос пароля (reauth challenge).
    /// ВАЖНО: после вызова `onPasswordRequired` кидает `PasswordChallengeError.passwordRequired`,
    /// чтобы базовый контроллер не завершал сценарий (`onFinish`) и не показывал "ошибку".
    func submit() async throws {
        guard validator.validate(email, for: .email).isValid else { return }
        
        onPasswordRequired?()
        throw PasswordChallengeError.passwordRequired
    }
    
    /// Второй шаг: выполняет реальную смену email (Variant A):
    /// 1) Auth updateEmail (через reauth по паролю)
    /// 2) ProfileRepository updateEmail
    func submit(withPassword password: String) async throws {
        guard validator.validate(email, for: .email).isValid else { return }
        
        try await authService.updateEmail(to: email, currentPassword: password)
        try await profileRepository.updateEmail(uid: userId, email: email)
        
        await MainActor.run {
            self.initialEmail = self.email
        }
    }
    
    // MARK: - Binding
    
    private func bindProfile() {
        profileRepository.observeProfile()
            .compactMap { $0 }
            .prefix(1)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                guard let self else { return }
                self.initialEmail = profile.email
                self.email = profile.email
            }
            .store(in: &bag)
        
        $email
            .removeDuplicates()
            .map { [validator] in
                validator.validate($0, for: .email).message
            }
            .assign(to: &$_emailError)
    }
}

// MARK: - BaseEditFieldViewModelProtocol

extension EditEmailViewModel: BaseEditFieldViewModelProtocol {
    var currentValue: String { currentEmail }
    var error: AnyPublisher<String?, Never> { emailError }
    func setValue(_ value: String) { setEmail(value) }
}
