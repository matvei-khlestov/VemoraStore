//
//  DeliveryAddressFormattingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import Foundation

protocol DeliveryAddressFormattingProtocol {
    /// Форматирует базовый адрес в части (город, улица, дом)
    func formatBaseAddress(_ baseAddress: String) -> [String]
}

