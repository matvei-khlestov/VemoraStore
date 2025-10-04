//
//  ProfileDTO.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import Foundation
import FirebaseCore

struct ProfileDTO: Equatable {
    let userId: String
    let name: String
    let email: String
    let phone: String
    let updatedAt: Date
    
    func toEntity() -> UserProfile {
        .init(
            userId: userId,
            name: name,
            email: email,
            phone: phone,
            updatedAt: updatedAt
        )
    }
}
