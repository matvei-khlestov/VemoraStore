//
//  PriceFormattingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Foundation

protocol PriceFormattingProtocol {
    /// Форматирует число в строку вида `"1 290 ₽"`
    func format(price: Double) -> String
}
