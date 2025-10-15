//
//  PriceFormatter.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Foundation

struct PriceFormatter: PriceFormattingProtocol {
    
    private let formatter: NumberFormatter
    
    init() {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.groupingSeparator = " "
        nf.maximumFractionDigits = 0
        self.formatter = nf
    }
    
    func format(price: Double) -> String {
        let numberString = formatter.string(from: NSNumber(value: price)) ?? "0"
        return "\(numberString) ₽"
    }
}
