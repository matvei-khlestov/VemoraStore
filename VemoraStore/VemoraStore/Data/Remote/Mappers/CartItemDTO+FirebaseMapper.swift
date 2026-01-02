//
//  CartItemDTO+FirebaseMapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 11.10.2025.
//

import FirebaseFirestore

/// Маппинг между `CartDTO` и документами Firestore (`/users/{uid}/cart/{productId}`).
///
/// Назначение:
/// - преобразование данных Firestore в модель `CartDTO` (`fromFirebase`);
/// - сериализация `CartDTO` обратно в словарь `[String: Any]` для записи в Firestore (`toFirebase`);
/// - безопасное восстановление полей с дефолтами и обработкой отсутствующих данных.
///
/// Особенности реализации:
/// - корректно обрабатывает опциональные поля (`imageURL`);
/// - использует `FieldValue.serverTimestamp()` для автоматического обновления времени `updatedAt`;
/// - обеспечивает совместимость типов (`Int`, `Double`, `String`, `Timestamp`);
/// - при чтении устанавливает безопасные значения по умолчанию, если данные отсутствуют в Firestore.
///
/// Используется в:
/// - `CartCollection` — для синхронизации корзины между Firestore и локальным хранилищем (`CoreDataCartStore`);
/// - репозиториях уровня Domain для маппинга DTO в сущности модели.

extension CartDTO {
    static func fromFirebase(uid: String, productId: String, data: [String: Any]) -> CartDTO {
        let title = data["title"] as? String ?? ""
        let price = data["price"] as? Double ?? 0
        let image = data["imageURL"] as? String
        let brandName = data["brandName"] as? String ?? ""
        let qty   = data["quantity"] as? Int ?? 0
        let ts    = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
        return .init(userId: uid, productId: productId, brandName: brandName, title: title, price: price, imageURL: image, quantity: qty, updatedAt: ts)
    }

    func toFirebase() -> [String: Any] {
        var dict: [String: Any] = [
            "title": title,
            "price": price,
            "quantity": quantity,
            "updatedAt": FieldValue.serverTimestamp(),
            "brandName": brandName
        ]
        if let imageURL { dict["imageURL"] = imageURL }
        return dict
    }
}
