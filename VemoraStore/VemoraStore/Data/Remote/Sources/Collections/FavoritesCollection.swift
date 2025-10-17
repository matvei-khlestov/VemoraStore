//
//  FavoritesCollection.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.10.2025.
//

import Foundation
import FirebaseFirestore
import Combine

/// Коллекция избранных товаров пользователя в Firestore (`/users/{uid}/favorites/{productId}`).
///
/// Отвечает за:
/// - загрузку списка избранных товаров пользователя (`fetch`);
/// - добавление и удаление товаров из избранного (`add`, `remove`);
/// - полную очистку коллекции избранного (`clear`);
/// - реактивное наблюдение за изменениями через Combine (`listen`).
///
/// Особенности реализации:
/// - использует `async/await` для асинхронных Firestore-запросов;
/// - поток `listen(uid:)` реализован через `PassthroughSubject`, с автоудалением слушателя при отмене подписки;
/// - структура коллекции: `users/{uid}/favorites/{productId}`;
/// - операции записи выполняются с `merge: true`, что позволяет частично обновлять данные;
/// - очистка (`clear`) реализована через `WriteBatch` для атомарного удаления всех документов.

final class FavoritesCollection: FavoritesCollectingProtocol {
    
    private let db = Firestore.firestore()
    private let users = "users"
    private let favorites = "favorites"

    private func col(uid: String) -> CollectionReference {
        db.collection(users).document(uid).collection(favorites)
    }

    func fetch(uid: String) async throws -> [FavoriteDTO] {
        let snap = try await col(uid: uid).getDocuments()
        return snap.documents.map {
            FavoriteDTO.fromFirebase(uid: uid, productId: $0.documentID, data: $0.data())
        }
    }

    func add(uid: String, dto: FavoriteDTO) async throws {
        try await col(uid: uid).document(dto.productId).setData(dto.toFirebase(), merge: true)
    }

    func remove(uid: String, productId: String) async throws {
        try await col(uid: uid).document(productId).delete()
    }

    func clear(uid: String) async throws {
        let docs = try await col(uid: uid).getDocuments()
        let batch = db.batch()
        for d in docs.documents { batch.deleteDocument(d.reference) }
        try await batch.commit()
    }

    func listen(uid: String) -> AnyPublisher<[FavoriteDTO], Never> {
        let subject = PassthroughSubject<[FavoriteDTO], Never>()
        let listener = col(uid: uid).addSnapshotListener { snap, _ in
            guard let snap else { subject.send([]); return }
            let items = snap.documents.map {
                FavoriteDTO.fromFirebase(uid: uid, productId: $0.documentID, data: $0.data())
            }
            subject.send(items)
        }
        return subject.handleEvents(receiveCancel: {
            listener.remove()
        }).eraseToAnyPublisher()
    }
}
