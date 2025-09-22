//
//  ConfirmationAlertType.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 22.09.2025.
//

import UIKit

enum ConfirmationAlertType {
    case logout
    case deleteAccount
    
    var title: String {
        switch self {
        case .logout:        return "Выйти из аккаунта?"
        case .deleteAccount: return "Удалить аккаунт?"
        }
    }
    
    var message: String {
        switch self {
        case .logout:
            return "Вы сможете войти снова в любой момент."
        case .deleteAccount:
            return "Это действие необратимо. Все данные будут удалены."
        }
    }
    
    var confirmTitle: String {
        switch self {
        case .logout:        return "Выйти"
        case .deleteAccount: return "Удалить аккаунт"
        }
    }
    
    var confirmStyle: UIAlertAction.Style { .destructive }
}
