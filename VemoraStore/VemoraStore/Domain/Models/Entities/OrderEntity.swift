//
//  OrderEntity.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Foundation

enum OrderStatus: String, Codable, Equatable {
    case assembling
    case ready
    case delivering
    case delivered
    case cancelled

    var badgeText: String {
        switch self {
        case .assembling:
            return "На сборке"
        case .ready:
            return "Готов к выдаче"
        case .delivering:
            return "В доставке"
        case .delivered:
            return "Доставлен"
        case .cancelled:
            return "Отменён"
        }
    }
}

struct OrderEntity: Equatable, Identifiable {
    let id: String
    let userId: String
    let createdAt: Date
    let updatedAt: Date
    let status: OrderStatus
    let receiveAddress: String
    let paymentMethod: String
    let comment: String
    let phoneE164: String?
    let items: [OrderItem]
}
