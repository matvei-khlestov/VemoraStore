//
//  FormTextFieldKind.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Foundation

enum FormTextFieldKind {
    case name, email, password, phone

    var title: String {
        switch self {
        case .name:     return "Имя"
        case .email:    return "E-mail"
        case .password: return "Пароль"
        case .phone:    return "Телефон"
        }
    }
    var placeholder: String {
        switch self {
        case .name:     return "Введите имя"
        case .email:    return "Введите e-mail"
        case .password: return "Введите пароль"
        case .phone:    return "+7 (___) ___-__-__"
        }
    }
}
