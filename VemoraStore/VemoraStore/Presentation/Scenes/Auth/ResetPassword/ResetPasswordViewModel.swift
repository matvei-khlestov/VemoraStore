//
//  ResetPasswordViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 21.09.2025.
//

import Foundation
import Combine

/// ViewModel `ResetPasswordViewModel` для экрана восстановления пароля.
///
/// Отвечает за:
/// - обработку и валидацию введённого e-mail;
/// - управление состоянием кнопки отправки через Combine;
/// - выполнение запроса на сброс пароля через `PasswordResetServiceProtocol`.
///
/// Особенности:
/// - реактивно обновляет ошибки поля e-mail;
/// - нормализует e-mail перед отправкой (обрезка пробелов, lowercase);
/// - предотвращает выполнение запроса при невалидных данных.

final class ResetPasswordViewModel: ResetPasswordViewModelProtocol {
    
    // MARK: - Dependencies
    
    private let service: PasswordResetServiceProtocol
    private let validator: FormValidatingProtocol
    
    // MARK: - State
    
    @Published private var email: String = ""
    @Published private var _emailError: String? = nil
    
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(
        service: PasswordResetServiceProtocol,
        validator: FormValidatingProtocol
    ) {
        self.service = service
        self.validator = validator
        
        $email
            .map { [validator] in validator.validate($0, for: .email).message }
            .assign(to: &$_emailError)
    }
    
    // MARK: - Outputs
    
    var emailError: AnyPublisher<String?, Never> {
        $_emailError.eraseToAnyPublisher()
    }
    
    var isSubmitEnabled: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($_emailError, $email)
            .map { errorMsg, email in
                errorMsg == nil && !email.isEmpty
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Inputs
    
    func setEmail(_ value: String) {
        email = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    // MARK: - Actions
    
    func resetPassword() async throws {
        guard validator.validate(email, for: .email).isValid else { return }
        try await service.sendPasswordReset(email: email)
    }
}
