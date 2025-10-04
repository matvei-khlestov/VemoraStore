//
//  ProfileCollection.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 02.10.2025.
//

import Foundation
import FirebaseFirestore
import Combine

final class ProfileCollection: ProfileCollectingProtocol {
    
    // MARK: - Deps
    
    private let db = Firestore.firestore()
    private let collectionName = "users"
    
    // MARK: - Create / Ensure
    
    func ensureInitialUserProfile(uid: String, name: String, email: String) async throws {
        let ref = db.collection(collectionName).document(uid)
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
    
    // MARK: - Fetch (one-shot)
    
    func fetchProfile(uid: String) async throws -> ProfileDTO? {
        let ref = db.collection(collectionName).document(uid)
        let snap = try await ref.getDocument()
        guard let data = snap.data() else { return nil }
        return ProfileDTO.fromFirebase(uid: uid, data: data)
    }
    
    // MARK: - Updates
    
    func updateName(uid: String, name: String) async throws {
        try await db.collection(collectionName).document(uid).setData([
            "name": name,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }
    
    func updateEmail(uid: String, email: String) async throws {
        try await db.collection(collectionName).document(uid).setData([
            "email": email,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }
    
    func updatePhone(uid: String, phone: String) async throws {
        try await db.collection(collectionName).document(uid).setData([
            "phone": phone,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }
    
    // MARK: - Realtime listen
    
    func listenProfile(uid: String) -> AnyPublisher<ProfileDTO?, Never> {
        let ref = db.collection(collectionName).document(uid)
        let subject = PassthroughSubject<ProfileDTO?, Never>()
        
        let listener = ref.addSnapshotListener { snap, _ in
            guard let snap = snap, let data = snap.data() else {
                subject.send(nil)
                return
            }
            subject.send(ProfileDTO.fromFirebase(uid: uid, data: data))
        }
        
        return subject
            .handleEvents(receiveCancel: { listener.remove() })
            .eraseToAnyPublisher()
    }
}
