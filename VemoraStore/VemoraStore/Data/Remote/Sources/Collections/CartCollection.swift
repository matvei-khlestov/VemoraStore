//
//  CartCollection.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 11.10.2025.
//

import Foundation
import FirebaseFirestore
import Combine

/// Коллекция корзины пользователя в Firestore (`/users/{uid}/cart/{productId}`).
///
/// Отвечает за:
/// - получение актуального состояния корзины пользователя (`fetchCart`);
/// - изменение количества товаров или добавление с инкрементом (`setQuantity`, `addOrAccumulate`);
/// - удаление конкретного товара или полной корзины (`remove`, `clear`);
/// - реактивное наблюдение за изменениями корзины через Combine (`listenCart`).
///
/// Особенности реализации:
/// - используется `async/await` для асинхронных Firestore операций;
/// - обновления количества реализованы через `FieldValue.increment`, что предотвращает гонки данных;
/// - очистка (`clear`) выполняется батчем (`WriteBatch`) для атомарного удаления всех документов;
/// - поток `listenCart` основан на `PassthroughSubject`, а слушатель (`ListenerRegistration`) автоматически удаляется при отмене подписки;
/// - структура коллекции: `users/{uid}/cart/{productId}`;
/// - при `quantity <= 0` товар удаляется автоматически из корзины.

final class CartCollection: CartCollectingProtocol {
    
    private let db = Firestore.firestore()
    private let users = "users"
    private let cart  = "cart"
    
    private func col(uid: String) -> CollectionReference {
        db.collection(users).document(uid).collection(cart)
    }
    
    func fetchCart(uid: String) async throws -> [CartDTO] {
        let snap = try await col(uid: uid).getDocuments()
        return snap.documents.map { doc in
            CartDTO.fromFirebase(uid: uid, productId: doc.documentID, data: doc.data())
        }
    }
    
    func setQuantity(uid: String, dto: CartDTO, quantity: Int) async throws {
        let ref = col(uid: uid).document(dto.productId)
        if quantity <= 0 {
            try await ref.delete()
            return
        }
        try await ref.setData([
            "title": dto.title,
            "price": dto.price,
            "imageURL": dto.imageURL as Any,
            "quantity": quantity,
            "brandName": dto.brandName,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }
    
    func addOrAccumulate(uid: String, dto: CartDTO, by delta: Int) async throws {
        guard delta != 0 else { return }
        let ref = col(uid: uid).document(dto.productId)
        try await ref.setData([
            "title": dto.title,
            "price": dto.price,
            "imageURL": dto.imageURL as Any,
            "quantity": FieldValue.increment(Int64(delta)),
            "brandName": dto.brandName,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }
    
    func remove(uid: String, productId: String) async throws {
        try await col(uid: uid).document(productId).delete()
    }
    
    func clear(uid: String) async throws {
        let docs = try await col(uid: uid).getDocuments()
        let batch = db.batch()
        for d in docs.documents {
            batch.deleteDocument(d.reference)
        }
        try await batch.commit()
    }
    
    func listenCart(uid: String) -> AnyPublisher<[CartDTO], Never> {
        let subject = PassthroughSubject<[CartDTO], Never>()
        let listener = col(uid: uid).addSnapshotListener { snap, _ in
            guard let snap else {
                subject.send([])
                return
            }
            let items = snap.documents.map { doc in
                CartDTO.fromFirebase(uid: uid, productId: doc.documentID, data: doc.data())
            }
            subject.send(items)
        }
        
        return subject
            .handleEvents(receiveCancel: { listener.remove() })
            .eraseToAnyPublisher()
    }
}
