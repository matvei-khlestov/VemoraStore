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
    case clearCart
    case clearFavorites
    
    var title: String {
        switch self {
        case .logout:
            return "Выйти из аккаунта?"
        case .deleteAccount:
            return "Удалить аккаунт?"
        case .clearCart:
            return "Вы уверены, что хотите очистить корзину?"
        case .clearFavorites:
            return "Вы уверены, что хотите очистить избранное?"
        }
    }
    
    var message: String {
        switch self {
        case .logout:
            return "Вы сможете войти снова в любой момент."
        case .deleteAccount:
            return "Это действие необратимо. Все данные будут удалены."
        case .clearCart, .clearFavorites:
            return "Это действие необратимо. Все данные будут удалены."
        }
    }
    
    var confirmTitle: String {
        switch self {
        case .logout:
            return "Выйти"
        case .deleteAccount:
            return "Удалить аккаунт"
        case .clearCart:
            return "Очистить корзину"
        case .clearFavorites:
            return "Очистить избранное"
        }
    }
    
    var confirmStyle: UIAlertAction.Style { .destructive }
}
