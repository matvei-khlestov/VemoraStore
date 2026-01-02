//
//  AppTab.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 31.08.2025.
//

import Foundation

enum AppTab: Int, CaseIterable {
    case catalog, favorites, cart, profile

    var title: String {
        switch self {
        case .catalog:
            return "Каталог"
        case .favorites:
            return "Избранное"
        case .cart:
            return "Корзина"
        case .profile:
            return "Профиль"
        }
    }

    var systemImage: String {
        switch self {
        case .catalog:
            return "square.grid.2x2"
        case .favorites:
            return "heart"
        case .cart:
            return "cart"
        case .profile:
            return "person.crop.circle"
        }
    }
}
