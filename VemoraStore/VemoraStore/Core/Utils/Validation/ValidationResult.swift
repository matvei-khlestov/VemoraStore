//
//  ValidationResult.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 19.09.2025.
//

import Foundation

struct ValidationResult {
    let isValid: Bool
    let messages: [String]
    var message: String? { messages.first }
}
