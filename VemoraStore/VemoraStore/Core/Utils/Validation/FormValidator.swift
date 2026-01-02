//
//  FormValidator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 19.09.2025.
//

import Foundation

struct FormValidator: FormValidatingProtocol {
    func validate(_ text: String, for field: AuthField) -> ValidationResult {
        switch field {
        case .name:
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            var errors: [String] = []
            if trimmed.count < 2 {
                errors.append("Имя должно содержать минимум 2 символа")
            }
            return .init(isValid: errors.isEmpty, messages: errors)
            
        case .email:
            let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
            let valid = text.range(of: pattern, options: .regularExpression) != nil
            let errors = valid ? [] : ["Введите корректный e-mail"]
            return .init(isValid: errors.isEmpty, messages: errors)
            
        case .password:
            var errors: [String] = []
            let pwd = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if pwd.count < 6 {
                errors.append("Минимум 6 символов")
            }
            if pwd.range(of: #"\s"#, options: .regularExpression) != nil {
                errors.append("Пароль не должен содержать пробелов")
            }
            if pwd.range(of: #"^[A-Za-z0-9!@#$%]+$"#, options: .regularExpression) == nil {
                errors.append("Допустимы: латиница, цифры, !@#$%")
            }
            if pwd.range(of: #"\d"#, options: .regularExpression) == nil {
                errors.append("Добавьте хотя бы одну цифру")
            }
            if pwd.range(of: #"[!@#$%]"#, options: .regularExpression) == nil {
                errors.append("Добавьте хотя бы один спецсимвол (!@#$%)")
            }
            if pwd.range(of: #"[A-Z]"#, options: .regularExpression) == nil {
                errors.append("Добавьте хотя бы одну заглавную букву")
            }
            return .init(isValid: errors.isEmpty, messages: errors)
            
        case .phone:
            let pattern = #"^\+7\d{10}$"#
            let valid = text.range(of: pattern, options: .regularExpression) != nil
            let errors = valid ? [] : ["Введите номер в формате +7 (XXX) XXX-XX-XX"]
            return .init(isValid: errors.isEmpty, messages: errors)
            
        case .comment:
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            var errors: [String] = []
            if trimmed.isEmpty {
                errors.append("Комментарий не может быть пустым")
            }
            if trimmed.count < 3 {
                errors.append("Комментарий слишком короткий")
            }
            if trimmed.count > 500 {
                errors.append("Комментарий слишком длинный (максимум 500 символов)")
            }
            return .init(isValid: errors.isEmpty, messages: errors)
        }
    }
}
