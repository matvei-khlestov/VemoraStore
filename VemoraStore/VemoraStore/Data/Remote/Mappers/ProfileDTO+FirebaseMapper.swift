//
//  ProfileDTO+FirebaseMapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 04.10.2025.
//

import Foundation
import FirebaseCore

extension ProfileDTO {
    static func fromFirebase(uid: String, data: [String: Any]) -> ProfileDTO {
        let name  = data["name"]  as? String ?? ""
        let email = data["email"] as? String ?? ""
        let phone = data["phone"] as? String ?? ""
        let ts = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
        return .init(userId: uid, name: name, email: email, phone: phone, updatedAt: ts)
    }
}
