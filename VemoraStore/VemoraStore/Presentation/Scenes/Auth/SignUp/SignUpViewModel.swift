//
//  SignUpViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 19.09.2025.
//

import Foundation
import Combine

final class SignUpViewModel: SignUpViewModelProtocol {
    
    private let auth: AuthServiceProtocol
    private let validator: AuthValidatingProtocol
    
    // State
    @Published private var name: String = ""
    @Published private var email: String = ""
    @Published private var password: String = ""
    @Published private var agreed: Bool = false
    
    @Published private var _nameError: String? = nil
    @Published private var _emailError: String? = nil
    @Published private var _passwordError: String? = nil
    @Published private var _agreementError: String? = nil
    
    private var bag = Set<AnyCancellable>()
    
    init(auth: AuthServiceProtocol, validator: AuthValidatingProtocol) {
        self.auth = auth
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
    
    // MARK: Bind outputs
    var nameError: AnyPublisher<String?, Never> { $_nameError.eraseToAnyPublisher() }
    var emailError: AnyPublisher<String?, Never> { $_emailError.eraseToAnyPublisher() }
    var passwordError: AnyPublisher<String?, Never> { $_passwordError.eraseToAnyPublisher() }
    var agreementError: AnyPublisher<String?, Never> { $_agreementError.eraseToAnyPublisher() }
    
    var isSubmitEnabled: AnyPublisher<Bool, Never> {
        // Convert each error stream to a Bool and type-erase
        let isNameValid: AnyPublisher<Bool, Never> =
        $_nameError.map { $0 == nil }.eraseToAnyPublisher()
        let isEmailValid: AnyPublisher<Bool, Never> =
        $_emailError.map { $0 == nil }.eraseToAnyPublisher()
        let isPasswordValid: AnyPublisher<Bool, Never> =
        $_passwordError.map { $0 == nil }.eraseToAnyPublisher()
        let isAgreementValid: AnyPublisher<Bool, Never> =
        $_agreementError.map { $0 == nil }.eraseToAnyPublisher()
        
        return Publishers.CombineLatest4(isNameValid, isEmailValid, isPasswordValid, isAgreementValid)
            .map { $0 && $1 && $2 && $3 }
            .eraseToAnyPublisher()
    }
    
    // MARK: Inputs
    func setName(_ value: String) { name = value }
    func setEmail(_ value: String) { email = value }
    func setPassword(_ value: String) { password = value }
    func setAgreement(_ value: Bool) { agreed = value }
    
    // MARK: Action
    func signUp() async throws {
        // финальная валидация (на случай)
        guard validator.validate(name, for: .name).isValid,
              validator.validate(email, for: .email).isValid,
              validator.validate(password, for: .password).isValid,
              agreed
        else { throw NSError(domain: "SignUp", code: 1, userInfo: [NSLocalizedDescriptionKey: "Проверьте корректность данных"]) }
        
        try await auth.signUp(email: email, password: password)
    }
}
