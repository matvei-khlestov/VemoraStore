//
//  ContactItem.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.09.2025.
//

import Foundation

enum ContactItem: CaseIterable {
    case phone
    case email
    case address
    
    var icon: String {
        switch self {
        case .phone:   "phone.fill"
        case .email:   "envelope.fill"
        case .address: "mappin.and.ellipse"
        }
    }
    
    var title: String {
        switch self {
        case .phone:   "Телефон"
        case .email:   "Email"
        case .address: "Адрес"
        }
    }
    
    var detail: String {
        switch self {
        case .phone:   "+7 (800) 555-35-35"
        case .email:   "support@vemora.ru"
        case .address: "Москва, Ходынский бульвар, 4"
        }
    }
    
    var action: () -> Void {
        switch self {
        case .phone:
            return { print("Нажали на телефон") }
        case .email:
            return { print("Нажали на email") }
        case .address:
            return { print("Нажали на адрес") }
        }
    }
}
