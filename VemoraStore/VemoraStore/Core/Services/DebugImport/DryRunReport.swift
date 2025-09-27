//
//  DryRunReport.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 26.09.2025.
//

import Foundation

// MARK: - Public reports

struct DryRunReport: Sendable {
    struct Section: Sendable {
        let name: String
        let willCreate: Int
        let willUpdate: Int
        let willSkip: Int
        let willDelete: Int
        let totalJSON: Int
    }
    let brands: Section
    let categories: Section
    let products: Section
    var summary: String {
        """
        Dry-run:
        \(brands.summaryLine)
        \(categories.summaryLine)
        \(products.summaryLine)
        """
    }
}

extension DryRunReport.Section {
    var summaryLine: String {
        let parts = [
            "new: \(willCreate)",
            "update: \(willUpdate)",
            "delete: \(willDelete)",
            "skip: \(willSkip) / total \(totalJSON)"
        ]
        return "• \(name.capitalized) — " + parts.joined(separator: ", ")
    }
}

/// Удобные алиасы, чтобы писать report.brands.new / update / skip / delete
extension DryRunReport.Section {
    var new: Int { willCreate }
    var update: Int { willUpdate }
    var skip: Int { willSkip }
    var delete: Int { willDelete }
}
