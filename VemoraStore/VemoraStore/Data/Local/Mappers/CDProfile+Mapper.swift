//
//  CDProfile+Mapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import CoreData

/// Расширение `CDProfile`, реализующее преобразование между слоями Core Data и Domain.
///
/// Обеспечивает корректную синхронизацию профиля пользователя между локальным (`CDProfile`)
/// и удалённым (`ProfileDTO`) представлением данных, а также создаёт доменную модель `UserProfile`.
///
/// Используется в:
/// - `ProfileLocalStore` для сохранения и обновления данных профиля в Core Data;
/// - `ProfileRepository` для маппинга данных между локальной и сетевой слоями.
extension CDProfile {
    
    /// Применяет данные из `ProfileDTO` к Core Data сущности `CDProfile`.
    /// - Parameter dto: DTO профиля, полученный с сервера.
    func apply(dto: ProfileDTO) {
        userId = dto.userId
        name = dto.name
        email = dto.email
        phone = dto.phone
        updatedAt = dto.updatedAt
    }
    
    /// Проверяет совпадение полей Core Data объекта с переданным DTO.
    /// Используется для предотвращения избыточных обновлений данных.
    /// - Parameter dto: DTO для сравнения.
    /// - Returns: `true`, если все поля идентичны.
    func matches(_ dto: ProfileDTO) -> Bool {
        (userId ?? "") == dto.userId &&
        (name ?? "") == dto.name &&
        (email ?? "") == dto.email &&
        (phone ?? "") == dto.phone &&
        (updatedAt ?? .distantPast) == dto.updatedAt
    }
}

/// Расширение `UserProfile`, предоставляющее инициализацию
/// доменной модели на основе Core Data сущности `CDProfile`.
///
/// Выполняет безопасное извлечение данных и создаёт объект `UserProfile`
/// для использования в UI и бизнес-логике приложения.
extension UserProfile {
    
    /// Инициализирует `UserProfile` из Core Data объекта `CDProfile`.
    /// - Parameter cd: Core Data объект профиля пользователя.
    init?(cd: CDProfile?) {
        guard let cd = cd,
              let userId = cd.userId,
              let name = cd.name,
              let email = cd.email,
              let phone = cd.phone,
              let updatedAt = cd.updatedAt else { return nil }
        
        self.init(
            userId: userId,
            name: name,
            email: email,
            phone: phone,
            updatedAt: updatedAt
        )
    }
}
