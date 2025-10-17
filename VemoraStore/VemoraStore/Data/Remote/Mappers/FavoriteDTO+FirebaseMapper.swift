//
//  FavoriteDTO+FirebaseMapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.10.2025.
//

import FirebaseFirestore

/// Маппинг между `FavoriteDTO` и документами Firestore (`/users/{uid}/favorites/{productId}`).
///
/// Назначение:
/// - преобразование данных Firestore в модель `FavoriteDTO` (`fromFirebase`);
/// - сериализация модели `FavoriteDTO` обратно в словарь `[String: Any]` для записи в Firestore (`toFirebase`);
/// - корректная обработка необязательных полей (`imageURL`);
/// - безопасное восстановление данных с дефолтами.
///
/// Особенности реализации:
/// - дата `updatedAt` восстанавливается из `Timestamp`, при отсутствии берётся `Date()`;
/// - используется `FieldValue.serverTimestamp()` для автоматического обновления времени при записи;
/// - обеспечивает совместимость типов (`Double`, `String`, `Timestamp`);
/// - в `toFirebase()` не добавляет `nil`-значения, формируя минимальный и безопасный документ.
///
/// Используется в:
/// - `FavoritesCollection` — для синхронизации локальных и удалённых избранных элементов;
/// - `CoreDataFavoritesStore` через DTO для обновления локальной базы.

extension FavoriteDTO {
    static func fromFirebase(uid: String, productId: String, data: [String: Any]) -> FavoriteDTO {
        let brandName = data["brandName"] as? String ?? ""
        let title = data["title"] as? String ?? ""
        let image = data["imageURL"] as? String
        let ts = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
        let price = data["price"] as? Double ?? 0
        return .init(
            userId: uid,
            productId: productId,
            brandName: brandName,
            title: title,
            imageURL: image,
            updatedAt: ts,
            price: price
        )
    }

    func toFirebase() -> [String: Any] {
        var dict: [String: Any] = [
            "brandName": brandName,
            "title": title,
            "updatedAt": FieldValue.serverTimestamp(),
            "price": price
        ]
        if let imageURL { dict["imageURL"] = imageURL }
        return dict
    }
}
