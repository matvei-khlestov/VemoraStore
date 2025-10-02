//
//  ResetPasswordViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 21.09.2025.
//

import Foundation
import Combine

final class ResetPasswordViewModel: ResetPasswordViewModelProtocol {

    private let service: PasswordResetServiceProtocol
    private let validator: FormValidatingProtocol

    @Published private var email: String = ""
    @Published private var _emailError: String? = nil

    private var bag = Set<AnyCancellable>()

    init(service: PasswordResetServiceProtocol, validator: FormValidatingProtocol) {
        self.service = service
        self.validator = validator

        // live-валидация email
        $email
            .map { [validator] in validator.validate($0, for: .email).message }
            .assign(to: &$_emailError)
    }

    // MARK: - Outputs
    var emailError: AnyPublisher<String?, Never> { $_emailError.eraseToAnyPublisher() }

    var isSubmitEnabled: AnyPublisher<Bool, Never> {
        $_emailError
            .map { $0 == nil && !self.email.isEmpty }
            .eraseToAnyPublisher()
    }

    // MARK: - Inputs
    func setEmail(_ value: String) { email = value.trimmingCharacters(in: .whitespacesAndNewlines) }

    // MARK: - Action
    func resetPassword() async throws {
        // финальная проверка на всякий
        guard validator.validate(email, for: .email).isValid
        else { throw NSError(domain: "ResetPassword", code: 1,
                             userInfo: [NSLocalizedDescriptionKey: "Введите корректный e-mail"]) }
        try await service.sendPasswordReset(email: email)
    }
}
