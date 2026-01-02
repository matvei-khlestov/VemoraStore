//
//  PreparedInputs.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 27.09.2025.
//

import Foundation

struct PreparedInputs {
    let brands: [Brand]
    let categories: [Category]
    let products: [Product]
    let checksums: [String: String]
    let store: ChecksumStoringProtocol
}
