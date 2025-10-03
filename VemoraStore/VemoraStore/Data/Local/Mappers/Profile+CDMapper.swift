//
//  Profile+CDMapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import CoreData

extension CDProfile {
    func apply(dto: ProfileDTO) {
        userId = dto.userId
        name = dto.name
        email = dto.email
        phone = dto.phone
        updatedAt = dto.updatedAt
    }
}

extension UserProfile {
    init?(cd: CDProfile?) {
        guard let cd = cd,
              let userId = cd.userId,
              let name = cd.name,
              let email = cd.email,
              let phone = cd.phone,
              let updatedAt = cd.updatedAt else { return nil }
        self.init(userId: userId, name: name, email: email, phone: phone, updatedAt: updatedAt)
    }
}
