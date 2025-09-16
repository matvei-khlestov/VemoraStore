//
//  ProfileGuestRow.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import UIKit

// MARK: - Data

enum ProfileGuestRow: Int, CaseIterable {
    case about, contact, privacy
    
    var title: String {
        switch self {
        case .about:   return "О нас"
        case .contact: return "Связаться с нами"
        case .privacy: return "Политика конфиденциальности"
        }
    }
    
    var systemImage: String {
        switch self {
        case .about:   return "storefront.fill"
        case .contact: return "phone.fill"
        case .privacy: return "lock.shield.fill"
        }
    }
}
