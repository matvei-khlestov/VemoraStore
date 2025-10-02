//
//  FormValidatingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 19.09.2025.
//

import Foundation

protocol FormValidatingProtocol {
    func validate(_ text: String, for field: AuthField) -> ValidationResult
}
