//
//  SignUpViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 19.09.2025.
//

import Foundation
import Combine

final class SignUpViewModel: SignUpViewModelProtocol {
    
    // MARK: - Dependencies
    
    private let auth: AuthServiceProtocol
    private let repos: RepositoryFactoryProtocol
    private let validator: FormValidatingProtocol
    
    private var bag = Set<AnyCancellable>()
    
    // MARK: - State
    
    @Published private var name: String = ""
    @Published private var email: String = ""
    @Published private var password: String = ""
    @Published private var agreed: Bool = false
    
    @Published private var _nameError: String? = nil
    @Published private var _emailError: String? = nil
    @Published private var _passwordError: String? = nil
    @Published private var _agreementError: String? = nil
    
    // MARK: - Init
    
    init(
        auth: AuthServiceProtocol,
        repos: RepositoryFactoryProtocol,
        validator: FormValidatingProtocol
    ) {
        self.auth = auth
        self.repos = repos
        self.validator = validator
        
        // live validation
        $name
            .map { [validator] in validator.validate($0, for: .name).message }
            .assign(to: &$_nameError)
        
        $email
            .map { [validator] in validator.validate($0, for: .email).message }
            .assign(to: &$_emailError)
        
        $password
            .map { [validator] in validator.validate($0, for: .password).message }
            .assign(to: &$_passwordError)
        
        $agreed
            .map { $0 ? nil : "Необходимо согласиться с политикой конфиденциальности" }
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
    
    func setName(_ value: String)     { name = value }
    func setEmail(_ value: String)    { email = value }
    func setPassword(_ value: String) { password = value }
    func setAgreement(_ value: Bool)  { agreed = value }
    
    // MARK: - Actions
    
    func signUp() async throws {
        // финальная валидация
        guard validator.validate(name, for: .name).isValid,
              validator.validate(email, for: .email).isValid,
              validator.validate(password, for: .password).isValid,
              agreed
        else {
            throw NSError(
                domain: "SignUp",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Проверьте корректность данных"]
            )
        }
        
        print("🟦 SignUpVM: start signUp with email=\(email), name=\(name)")
        
        // 1. создаём пользователя
        try await auth.signUp(email: email, password: password)
        print("✅ SignUpVM: auth.signUp success for email=\(email)")
        
        // 2. берём uid
        guard let uid = auth.currentUserId else {
            throw NSError(
                domain: "SignUp",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Не удалось получить идентификатор пользователя"]
            )
        }
        print("🆔 SignUpVM: obtained uid=\(uid)")
        
        // 3. создаём репозиторий и профиль
        let repo = repos.profileRepository(for: uid)
        try await repo.ensureInitialProfile(uid: uid, name: name, email: email)
        
        print("✅ SignUpVM: profile ensured & refreshed for uid=\(uid)")
    }
}
