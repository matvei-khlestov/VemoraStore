//
//  Category.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation

struct Category: Codable, Hashable {
    let id: String
    let name: String
    let icon: URL?
}
