//
//  ProfileUserRow.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 17.09.2025.
//

import Foundation

enum ProfileUserRow: Int, CaseIterable {
    case editProfile
    case orders
    case about
    case contact
    case privacy
    
    var title: String {
        switch self {
        case .editProfile: return "Редактировать профиль"
        case .orders:      return "Мои заказы"
        case .about:       return "О нас"
        case .contact:     return "Связаться с нами"
        case .privacy:     return "Политика конфиденциальности"
        }
    }
    
    var systemImage: String {
        switch self {
        case .editProfile: return "person.crop.circle.badge.plus"
        case .orders:      return "bag.fill"
        case .about:       return "storefront.fill"
        case .contact:     return "phone.fill"
        case .privacy:     return "lock.shield.fill"
        }
    }
}
