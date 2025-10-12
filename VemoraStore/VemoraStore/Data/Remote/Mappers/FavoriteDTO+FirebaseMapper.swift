//
//  FavoriteDTO+FirebaseMapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.10.2025.
//

import FirebaseFirestore

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
