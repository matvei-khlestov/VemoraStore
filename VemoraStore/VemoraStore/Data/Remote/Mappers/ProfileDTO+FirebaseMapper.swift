//
//  ProfileDTO+FirebaseMapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 04.10.2025.
//

import Foundation
import FirebaseCore

/// Маппинг между `ProfileDTO` и документами Firestore (`/users/{uid}`).
///
/// Назначение:
/// - преобразование документа пользователя из Firestore в модель `ProfileDTO`;
/// - безопасная обработка данных профиля с дефолтными значениями.
///
/// Особенности реализации:
/// - поля `name`, `email`, `phone` читаются из Firestore с подстановкой пустых строк при их отсутствии;
/// - дата обновления (`updatedAt`) восстанавливается из `Timestamp`, при отсутствии — текущая дата;
/// - метод используется только для десериализации данных из Firestore (обратное преобразование не требуется);
/// - UID передаётся отдельно, чтобы не зависеть от содержимого документа.
///
/// Используется в:
/// - `ProfileCollection` при загрузке и прослушивании данных профиля;
/// - `CoreDataProfileStore` через репозиторий для синхронизации с локальным хранилищем (`CDProfile`).

extension ProfileDTO {
    static func fromFirebase(uid: String, data: [String: Any]) -> ProfileDTO {
        let name  = data["name"]  as? String ?? ""
        let email = data["email"] as? String ?? ""
        let phone = data["phone"] as? String ?? ""
        let ts = (data["updatedAt"] as? Timestamp)?.dateValue() ?? Date()
        return .init(userId: uid, name: name, email: email, phone: phone, updatedAt: ts)
    }
}
