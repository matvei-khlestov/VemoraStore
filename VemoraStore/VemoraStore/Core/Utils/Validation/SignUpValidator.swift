//
//  AuthValidator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 19.09.2025.
//

import Foundation


final class AuthValidator: AuthValidatingProtocol {
    func validate(_ text: String, for field: SignUpField) -> ValidationResult {
        switch field {
        case .name:
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.count >= 2 else {
                return .init(isValid: false, message: "Имя должно содержать минимум 2 символа")
            }
            return .init(isValid: true, message: nil)

        case .email:
            let pattern =
            #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
            let valid = text.range(of: pattern, options: .regularExpression) != nil
            return .init(isValid: valid, message: valid ? nil : "Введите корректный e-mail")

        case .password:
            // ≥ 6 символов, хотя бы 1 цифра
            let lengthOK = text.count >= 6
            let hasDigit = text.range(of: #".*\d+.*"#, options: .regularExpression) != nil
            guard lengthOK && hasDigit else {
                return .init(isValid: false, message: "Пароль ≥ 6 символов и содержит цифру")
            }
            return .init(isValid: true, message: nil)
        }
    }
}
