//
//  ValidatorFake.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.10.2025.
//

import Foundation
@testable import VemoraStore

final class ValidatorFake: FormValidatingProtocol {

    typealias Rule = (_ text: String) -> ValidationResult

    private var rules: [AuthField: Rule] = [:]

    init(rules: [AuthField: Rule] = [:]) {
        self.rules = rules
    }

    func setRule(for field: AuthField, rule: @escaping Rule) {
        rules[field] = rule
    }

    func validate(_ text: String, for field: AuthField) -> ValidationResult {
        if let rule = rules[field] {
            return rule(text)
        } else {
            return ValidationResult(isValid: true, messages: [])
        }
    }
}

