//
//  ProfileCollection.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 02.10.2025.
//

import Foundation
import FirebaseFirestore

final class ProfileCollection: ProfileCollectingProtocol {
    private let db = Firestore.firestore()

    func ensureInitialUserProfile(uid: String, name: String, email: String) async throws {
        let ref = db.collection("users").document(uid)
        let snap = try await ref.getDocument()
        if snap.exists {
            try await ref.setData([
                "name": name,
                "email": email,
                "updatedAt": FieldValue.serverTimestamp()
            ], merge: true)
            return
        }
        try await ref.setData([
            "name": name,
            "email": email,
            "phone": "",
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }

    func fetchProfile(uid: String) async throws -> ProfileDTO? {
        let ref = db.collection("users").document(uid)
        let snap = try await ref.getDocument()
        guard let data = snap.data() else { return nil }
        return ProfileDTO.fromFirebase(uid: uid, data: data)
    }

    func updateName(uid: String, name: String) async throws {
        try await db.collection("users").document(uid).setData([
            "name": name, "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }

    func updateEmail(uid: String, email: String) async throws {
        try await db.collection("users").document(uid).setData([
            "email": email, "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }

    func updatePhone(uid: String, phone: String) async throws {
        try await db.collection("users").document(uid).setData([
            "phone": phone, "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }
}

private extension ProfileDTO {
    static func fromFirebase(uid: String, data: [String: Any]) -> ProfileDTO {
        let name  = data["name"]  as? String ?? ""
        let email = data["email"] as? String ?? ""
        let phone = data["phone"] as? String ?? ""
        let ts    = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
        return .init(userId: uid, name: name, email: email, phone: phone, updatedAt: ts)
    }
}
