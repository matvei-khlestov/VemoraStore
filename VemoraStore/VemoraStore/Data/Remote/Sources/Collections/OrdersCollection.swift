//
//  OrdersCollection.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Foundation
import Combine
import FirebaseFirestore

/// Коллекция заказов пользователя в Firestore (`/users/{uid}/orders/{orderId}`).
///
/// Отвечает за:
/// - загрузку и синхронизацию заказов пользователя с Firestore;
/// - создание и обновление заказов (включая изменение статуса);
/// - реактивное наблюдение за изменениями через Combine (`listenOrders`);
/// - полную очистку коллекции заказов пользователя (`clear`).
///
/// Особенности реализации:
/// - Firestore-операции выполняются асинхронно (`async/await`);
/// - для `listenOrders` используются `PassthroughSubject` и `ListenerRegistration`,
///   что обеспечивает непрерывный Combine-поток обновлений без разрывов;
/// - подписки (`listeners`, `subjects`) кешируются по `uid` для предотвращения дублирования;
/// - метод `clear(uid:)` выполняет пакетное удаление (batch delete) с разбиением по 450 документов;
/// - ошибки логируются в консоль, но не прерывают поток данных.

final class OrdersCollection: OrdersCollectingProtocol {
    
    // MARK: - Deps
    private let db: Firestore
    private let collectionName = "orders"
    
    // MARK: - Streams
    /// Храним активные листенеры по uid (если нужно несколько одновременно)
    private var listeners: [String: ListenerRegistration] = [:]
    private var subjects:  [String: PassthroughSubject<[OrderDTO], Never>] = [:]
    
    // MARK: - Init
    init(db: Firestore = Firestore.firestore()) {
        self.db = db
    }
    
    deinit {
        listeners.values.forEach { $0.remove() }
        listeners.removeAll()
        subjects.removeAll()
    }
    
    // MARK: - API
    
    func fetchOrders(uid: String) async throws -> [OrderDTO] {
        let q = userOrders(uid: uid)
            .order(by: "createdAt", descending: true)
        
        let snap = try await q.getDocuments()
        return snap.documents.map { doc in
            OrderDTO.fromFirebase(id: doc.documentID, uid: uid, data: doc.data())
        }
    }
    
    func createOrder(uid: String, dto: OrderDTO) async throws {
        let ref: DocumentReference
        if dto.id.isEmpty {
            ref = userOrders(uid: uid).document() // авто-ID
        } else {
            ref = userOrders(uid: uid).document(dto.id)
        }
        try await ref.setData(dto.toFirebase(), merge: false)
    }
    
    func updateStatus(uid: String, orderId: String, status: OrderStatus) async throws {
        let ref = userOrders(uid: uid).document(orderId)
        try await ref.updateData([
            "status": status.rawValue,
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }
    
    func listenOrders(uid: String) -> AnyPublisher<[OrderDTO], Never> {
        if let subj = subjects[uid] {
            return subj.eraseToAnyPublisher()
        }
        
        let subj = PassthroughSubject<[OrderDTO], Never>()
        subjects[uid] = subj
        
        let q = userOrders(uid: uid)
            .order(by: "createdAt", descending: true)
        
        let reg = q.addSnapshotListener { [weak self] snapshot, error in
            guard self != nil else { return }
            if let docs = snapshot?.documents {
                let dtos = docs.map { OrderDTO.fromFirebase(id: $0.documentID, uid: uid, data: $0.data()) }
                subj.send(dtos)
            } else {
                // В случае ошибки — не рвём стрим, просто отправим пустой массив
                subj.send([])
                if let error { print("❌ OrdersCollection.listenOrders error: \(error)") }
            }
        }
        listeners[uid] = reg
        
        return subj.eraseToAnyPublisher()
    }
    
    func clear(uid: String) async throws {
        // Мягкий батч-делит всех заказов пользователя
        let col = userOrders(uid: uid)
        let snap = try await col.getDocuments()
        guard snap.count > 0 else { return }
        
        // Firestore batch: по 500 опер. максимум; разобьём при необходимости
        let chunks = snap.documents.chunked(into: 450)
        for chunk in chunks {
            let batch = db.batch()
            chunk.forEach { batch.deleteDocument($0.reference) }
            try await batch.commit()
        }
    }
}

// MARK: - Helpers

private extension OrdersCollection {
    func userOrders(uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection(collectionName)
    }
}

// MARK: - Small util

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [self] }
        var chunks: [[Element]] = []
        chunks.reserveCapacity((count / size) + 1)
        var idx = startIndex
        while idx < endIndex {
            let end = index(idx, offsetBy: size, limitedBy: endIndex) ?? endIndex
            chunks.append(Array(self[idx..<end]))
            idx = end
        }
        return chunks
    }
}
