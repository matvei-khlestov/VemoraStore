//
//  CDProfile+MatchingHelper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 04.10.2025.
//

import Foundation

extension CDProfile {
    /// Точная проверка на совпадение всех полей, чтобы не делать лишних save()
    func matches(_ dto: ProfileDTO) -> Bool {
        (userId ?? "") == dto.userId &&
        (name ?? "") == dto.name   &&
        (email ?? "") == dto.email  &&
        (phone ?? "") == dto.phone  &&
        (updatedAt ?? .distantPast) == dto.updatedAt
    }
}
