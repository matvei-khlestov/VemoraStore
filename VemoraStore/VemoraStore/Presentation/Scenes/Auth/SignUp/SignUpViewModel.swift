//
//  SignUpViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 19.09.2025.
//

import Foundation
import Combine

/// ViewModel `SignUpViewModel` для экрана регистрации.
///
/// Отвечает за:
/// - обработку и валидацию пользовательского ввода (имя, e-mail, пароль);
/// - проверку согласия с политикой конфиденциальности;
/// - активацию кнопки "Зарегистрироваться" при корректных данных;
/// - выполнение регистрации пользователя через `AuthServiceProtocol`;
/// - создание первичного профиля через `ProfileRepository`.
///
/// Архитектура и зависимости:
/// - Использует Combine для реактивной обработки ошибок валидации;
/// - Работает с `FormValidatingProtocol` для проверок формата данных;
/// - Через замыкание `makeProfileRepository` получает нужный `ProfileRepository` после регистрации.
///
/// Особенности:
/// - Автоматически обновляет ошибки при изменении значений полей;
/// - Паблишеры ошибок (`nameError`, `emailError`, `passwordError`, `agreementError`);
/// - Паблишер `isSubmitEnabled` активирует кнопку сабмита при валидных данных;
/// - Метод `signUp()` асинхронно выполняет регистрацию и создаёт профиль пользователя.

final class SignUpViewModel: SignUpViewModelProtocol {
    
    // MARK: - Deps
    
    private let auth: AuthServiceProtocol
    private let validator: FormValidatingProtocol
    private let makeProfileRepository: (String) -> ProfileRepository
    
    // MARK: - State
    
    @Published private var name = ""
    @Published private var email = ""
    @Published private var password = ""
    @Published private var agreed = false
    
    @Published private var _nameError: String?
    @Published private var _emailError: String?
    @Published private var _passwordError: String?
    @Published private var _agreementError: String?
    
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(
        auth: AuthServiceProtocol,
        validator: FormValidatingProtocol,
        makeProfileRepository: @escaping (String) -> ProfileRepository
    ) {
        self.auth = auth
        self.validator = validator
        self.makeProfileRepository = makeProfileRepository
        
        $name
            .map {
                [validator] in
                validator.validate($0, for: .name).message
            }
            .assign(to: &$_nameError)
        
        $email
            .map {
                [validator] in
                validator.validate($0, for: .email).message
            }
            .assign(to: &$_emailError)
        
        $password
            .map {
                [validator] in
                validator.validate($0, for: .password).message
            }
            .assign(to: &$_passwordError)
        
        $agreed
            .map {
                $0 ? nil : "Необходимо согласиться с политикой конфиденциальности"
            }
            .assign(to: &$_agreementError)
    }
    
    // MARK: - Outputs
    
    var nameError: AnyPublisher<String?, Never> {
        $_nameError.eraseToAnyPublisher()
    }
    
    var emailError: AnyPublisher<String?, Never> {
        $_emailError.eraseToAnyPublisher()
    }
    
    var passwordError: AnyPublisher<String?, Never> {
        $_passwordError.eraseToAnyPublisher()
    }
    
    var agreementError: AnyPublisher<String?, Never> {
        $_agreementError.eraseToAnyPublisher()
    }
    
    var isSubmitEnabled: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest4(
            $_nameError.map { $0 == nil },
            $_emailError.map { $0 == nil },
            $_passwordError.map { $0 == nil },
            $_agreementError.map { $0 == nil }
        )
        .map { $0 && $1 && $2 && $3 }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Inputs
    
    func setName(_ v: String) { name = v }
    func setEmail(_ v: String) { email = v }
    func setPassword(_ v: String) { password = v }
    func setAgreement(_ v: Bool) { agreed = v }
    
    // MARK: - Actions
    
    func signUp() async throws {
        guard validator.validate(name, for: .name).isValid,
              validator.validate(email, for: .email).isValid,
              validator.validate(password, for: .password).isValid,
              agreed else { return }
        
        try await auth.signUp(email: email, password: password)
        
        guard let uid = auth.currentUserId, !uid.isEmpty else { return }
        
        let profileRepo = makeProfileRepository(uid)
        
        try await profileRepo.ensureInitialProfile(uid: uid, name: name, email: email)
    }
}
