//
//  ImportError.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 26.09.2025.
//

import Foundation

enum ImportError: Error {
    case fileNotFound(String)
    case decodingFailed(String, underlying: Error)
    case firestoreNotConfigured
}
