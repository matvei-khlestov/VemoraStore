//
//  SectionWriteResult.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 26.09.2025.
//

import Foundation

public struct SectionWriteResult {
    let upserted: Int
    let deleted: Int
    var didWrite: Bool { upserted > 0 || deleted > 0 }
}
