//
//  EditProfileRow.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Foundation

enum EditProfileRow: Int, CaseIterable {
    case name
    case email
    case phone
    
    var icon: String {
        switch self {
        case .name:  "person.fill"
        case .email: "envelope.fill"
        case .phone: "phone.fill"
        }
    }
    
    var title: String {
        switch self {
        case .name:  "Имя"
        case .email: "Почта"
        case .phone: "Телефон"
        }
    }
    
    func detail(from vm: EditProfileViewModelProtocol) -> String {
        switch self {
        case .name:  vm.name
        case .email: vm.email
        case .phone: vm.phone
        }
    }
}
