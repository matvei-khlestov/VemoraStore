//
//  ProfileDTO.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import Foundation
import FirebaseCore

/// Data Transfer Object, представляющий профиль пользователя (`ProfileDTO`).
///
/// Назначение:
/// - используется для обмена данными между удалёнными источниками (Firebase, REST API)
///   и внутренними слоями приложения (Domain, Persistence);
/// - обеспечивает изоляцию модели данных от бизнес-логики и UI.
///
/// Состав:
/// - `userId`: уникальный идентификатор пользователя;
/// - `name`: имя пользователя;
/// - `email`: адрес электронной почты;
/// - `phone`: номер телефона в формате строки;
/// - `updatedAt`: дата последнего обновления данных.
///
/// Особенности реализации:
/// - метод `toEntity()` преобразует DTO в доменную модель `UserProfile`;
/// - применяется в `ProfileCollection` и `CoreDataProfileStore`
///   для синхронизации данных между Firebase и локальным хранилищем (`CDProfile`);
/// - `Equatable` используется для эффективных сравнений и предотвращения лишних апдейтов в Combine-пайплайнах.

struct ProfileDTO: Equatable {
    let userId: String
    let name: String
    let email: String
    let phone: String
    let updatedAt: Date
    
    func toEntity() -> UserProfile {
        .init(
            userId: userId,
            name: name,
            email: email,
            phone: phone,
            updatedAt: updatedAt
        )
    }
}
