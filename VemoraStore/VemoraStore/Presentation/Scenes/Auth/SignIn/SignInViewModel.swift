//
//  SignInViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 21.09.2025.
//

import Foundation
import Combine

final class SignInViewModel: SignInViewModelProtocol {

    private let auth: AuthServiceProtocol
    private let validator: AuthValidatingProtocol

    // State
    @Published private var email: String = ""
    @Published private var password: String = ""

    @Published private var _emailError: String? = nil
    @Published private var _passwordError: String? = nil

    private var bag = Set<AnyCancellable>()

    init(auth: AuthServiceProtocol, validator: AuthValidatingProtocol) {
        self.auth = auth
        self.validator = validator

        // live validation
        $email
            .map { [validator] in validator.validate($0, for: .email).message }
            .assign(to: &$_emailError)

        $password
            .map { [validator] in validator.validate($0, for: .password).message }
            .assign(to: &$_passwordError)
    }

    // Outputs
    var emailError: AnyPublisher<String?, Never> { $_emailError.eraseToAnyPublisher() }
    var passwordError: AnyPublisher<String?, Never> { $_passwordError.eraseToAnyPublisher() }

    var isSubmitEnabled: AnyPublisher<Bool, Never> {
        let isEmailValid = $_emailError.map { $0 == nil }
        let isPasswordValid = $_passwordError.map { $0 == nil }
        return Publishers.CombineLatest(isEmailValid, isPasswordValid)
            .map { $0 && $1 }
            .eraseToAnyPublisher()
    }

    // Inputs
    func setEmail(_ value: String) { email = value }
    func setPassword(_ value: String) { password = value }

    // Actions
    func signIn() async throws {
        guard validator.validate(email, for: .email).isValid,
              validator.validate(password, for: .password).isValid
        else {
            throw NSError(domain: "SignIn", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Проверьте корректность данных"])
        }
        try await auth.signIn(email: email, password: password)
    }
}
