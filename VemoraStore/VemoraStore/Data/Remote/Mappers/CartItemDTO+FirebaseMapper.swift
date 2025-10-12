//
//  CartItemDTO+FirebaseMapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 11.10.2025.
//

import FirebaseFirestore

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
