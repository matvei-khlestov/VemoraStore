//
//  OrderDTO+FirebaseMapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import FirebaseFirestore

extension OrderDTO {
    static func fromFirebase(id: String, uid: String, data: [String: Any]) -> OrderDTO {
        let created = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        let updated = (data["updatedAt"] as? Timestamp)?.dateValue() ?? created
        let statusRaw = data["status"] as? String ?? OrderStatus.assembling.rawValue
        let status = OrderStatus(rawValue: statusRaw) ?? .assembling
        let address = data["receiveAddress"] as? String ?? ""
        let payment = data["paymentMethod"] as? String ?? ""
        let comment = data["comment"] as? String
        let phone = data["phoneE164"] as? String

        let itemsArr = data["items"] as? [[String: Any]] ?? []
        let items: [OrderItemDTO] = itemsArr.map { m in
            OrderItemDTO(
                productId: m["productId"] as? String ?? "",
                brandName: m["brandName"] as? String ?? "",
                title:     m["title"] as? String ?? "",
                price:     m["price"] as? Double ?? 0,
                imageURL:  m["imageURL"] as? String,
                quantity:  m["quantity"] as? Int ?? 0
            )
        }

        return .init(
            id: id,
            userId: uid,
            createdAt: created,
            updatedAt: updated,
            status: status,
            receiveAddress: address,
            paymentMethod: payment,
            comment: comment,
            phoneE164: phone,
            items: items
        )
    }

    func toFirebase() -> [String: Any] {
        let itemsArray: [[String: Any]] = items.map {
            var d: [String: Any] = [
                "productId": $0.productId,
                "brandName": $0.brandName,
                "title":     $0.title,
                "price":     $0.price,
                "quantity":  $0.quantity
            ]
            if let img = $0.imageURL { d["imageURL"] = img }
            return d
        }
        var dict: [String: Any] = [
            "userId": userId,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp(),
            "status": status.rawValue,
            "receiveAddress": receiveAddress,
            "paymentMethod": paymentMethod,
            "items": itemsArray
        ]
        if let comment { dict["comment"] = comment }
        if let phoneE164 { dict["phoneE164"] = phoneE164 }
        return dict
    }
}
