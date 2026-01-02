//
//  CatalogCollections.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import Foundation
import FirebaseFirestore
import Combine

/// Коллекции каталога в Firestore (`/products`, `/categories`, `/brands`).
///
/// Отвечает за:
/// - однократную загрузку активных продуктов, категорий и брендов (`fetchProducts`, `fetchCategories`, `fetchBrands`);
/// - реактивное наблюдение за изменениями каталога через Combine (`listenProducts`, `listenCategories`, `listenBrands`);
/// - преобразование данных Firestore в DTO-модели (`ProductDTO`, `CategoryDTO`, `BrandDTO`).
///
/// Особенности реализации:
/// - все запросы к Firestore выполняются асинхронно с помощью `async/await`;
/// - используется фильтрация `isActive == true` для исключения неактивных элементов;
/// - реализация слушателей (`addSnapshotListener`) обеспечивает live-обновления данных каталога без перезапросов;
/// - каждый слушатель возвращает Combine-поток, автоматически удаляющий `ListenerRegistration` при отмене подписки;
/// - коллекции Firestore:
///   - `products` — все товары магазина;
///   - `categories` — активные категории каталога;
///   - `brands` — активные бренды.

final class CatalogCollections: CatalogCollectingProtocol {
    
    // MARK: - Firestore
    
    private let db = Firestore.firestore()
    private let products = "products"
    private let categories = "categories"
    private let brands = "brands"
    
    // MARK: - One shot
    
    /// Холодная загрузка продуктов (только активные)
    func fetchProducts() async throws -> [ProductDTO] {
        let qs = try await db.collection(products)
            .whereField("isActive", isEqualTo: true)
            .getDocuments()
        return qs.documents.map {
            ProductDTO.fromFirebase(id: $0.documentID, data: $0.data())
        }
    }
    
    /// Холодная загрузка категорий (только активные)
    func fetchCategories() async throws -> [CategoryDTO] {
        let qs = try await db.collection(categories)
            .whereField("isActive", isEqualTo: true)
            .getDocuments()
        return qs.documents.map {
            CategoryDTO.fromFirebase(id: $0.documentID, data: $0.data())
        }
    }
    
    /// Холодная загрузка брендов (только активные)
    func fetchBrands() async throws -> [BrandDTO] {
        let qs = try await db.collection(brands)
            .whereField("isActive", isEqualTo: true)
            .getDocuments()
        return qs.documents.map {
            BrandDTO.fromFirebase(id: $0.documentID, data: $0.data())
        }
    }
    
    // MARK: - Realtime
    
    /// Слушатель продуктов
    func listenProducts() -> AnyPublisher<[ProductDTO], Never> {
        let subject = PassthroughSubject<[ProductDTO], Never>()
        let listener = db.collection(products)
            .addSnapshotListener { snap, _ in
                guard let snap else {
                    subject.send([])
                    return
                }
                let dtos = snap.documents.map {
                    ProductDTO.fromFirebase(id: $0.documentID, data: $0.data())
                }
                subject.send(dtos)
            }
        return subject
            .handleEvents(receiveCancel: { listener.remove() })
            .eraseToAnyPublisher()
    }
    
    /// Слушатель категорий
    func listenCategories() -> AnyPublisher<[CategoryDTO], Never> {
        let subject = PassthroughSubject<[CategoryDTO], Never>()
        let listener = db.collection(categories)
            .addSnapshotListener { snap, _ in
                guard let snap else {
                    subject.send([])
                    return
                }
                let dtos = snap.documents.map {
                    CategoryDTO.fromFirebase(id: $0.documentID, data: $0.data())
                }
                subject.send(dtos)
            }
        return subject
            .handleEvents(receiveCancel: { listener.remove() })
            .eraseToAnyPublisher()
    }
    
    /// Слушатель брендов
    func listenBrands() -> AnyPublisher<[BrandDTO], Never> {
        let subject = PassthroughSubject<[BrandDTO], Never>()
        let listener = db.collection(brands)
            .addSnapshotListener { snap, _ in
                guard let snap else {
                    subject.send([])
                    return
                }
                let dtos = snap.documents.map {
                    BrandDTO.fromFirebase(id: $0.documentID, data: $0.data())
                }
                subject.send(dtos)
            }
        return subject
            .handleEvents(receiveCancel: { listener.remove() })
            .eraseToAnyPublisher()
    }
}
