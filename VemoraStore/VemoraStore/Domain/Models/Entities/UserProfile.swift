//
//  UserProfile.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import Foundation

struct UserProfile: Equatable {
    let userId: String
    var name: String
    var email: String
    var phone: String
    var updatedAt: Date
}
