//
//  PriceFormatterMock.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import Foundation
@testable import VemoraStore

final class PriceFormatterMock: PriceFormattingProtocol {
    var stub: (Double) -> String = { price in "formatted:\(price)" }
    func format(price: Double) -> String { stub(price) }
}
