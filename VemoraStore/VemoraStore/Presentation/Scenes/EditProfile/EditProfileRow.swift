//
//  EditProfileRow.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Foundation

enum Row: Int, CaseIterable {
    case name, email, phone
    
    var icon: String {
        switch self {
        case .name: return "person.fill"
        case .email: return "envelope.fill"
        case .phone: return "phone.fill"
        }
    }
    
    var title: String {
        switch self {
        case .name: return "Имя"
        case .email: return "Почта"
        case .phone: return "Телефон"
        }
    }
    
    func detail(from vm: EditProfileViewModelProtocol) -> String {
        switch self {
        case .name:  return vm.name
        case .email: return vm.email
        case .phone: return vm.phone
        }
    }
}
