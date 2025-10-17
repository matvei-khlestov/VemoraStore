//
//  CDBrand+Mapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 09.10.2025.
//

import CoreData
import Foundation

/// Расширение `CDBrand`, реализующее маппинг между слоями Core Data и Domain.
///
/// Отвечает за преобразование данных между `BrandDTO` (сетевой моделью)
/// и `CDBrand` (локальной моделью Core Data), а также обеспечивает
/// создание доменной модели `Brand` из Core Data сущности.
///
/// Используется в:
/// - `CatalogLocalStore` и `CatalogRepository`
/// для синхронизации данных брендов между сервером и локальной БД.
extension CDBrand {
    
    /// Применяет данные из `BrandDTO` к Core Data сущности `CDBrand`.
    /// - Parameter dto: DTO бренда, полученный из API.
    func apply(dto: BrandDTO) {
        id        = dto.id
        name      = dto.name
        imageURL  = dto.imageURL
        isActive  = dto.isActive
        createdAt = dto.createdAt
        updatedAt = dto.updatedAt
    }
    
    /// Проверяет совпадение полей сущности с переданным `BrandDTO`.
    /// Используется для предотвращения избыточных обновлений.
    /// - Parameter dto: DTO для сравнения.
    /// - Returns: `true`, если все поля идентичны.
    func matches(_ dto: BrandDTO) -> Bool {
        (id ?? "") == dto.id &&
        (name ?? "") == dto.name &&
        (imageURL ?? "") == dto.imageURL &&
        isActive == dto.isActive &&
        (createdAt ?? .distantPast) == dto.createdAt &&
        (updatedAt ?? .distantPast) == dto.updatedAt
    }
}

/// Расширение `Brand`, предоставляющее инициализацию доменной модели
/// на основе Core Data сущности `CDBrand`.
///
/// Выполняет безопасное извлечение и форматирование дат в ISO 8601 формат
/// для унификации данных в Domain-слое.
extension Brand {
    
    /// Инициализирует доменную модель `Brand` из Core Data сущности `CDBrand`.
    /// - Parameter cd: Объект `CDBrand` из локального хранилища.
    init?(cd: CDBrand?) {
        guard
            let cd,
            let id = cd.id,
            let name = cd.name,
            let imageURL = cd.imageURL,
            let createdAt = cd.createdAt,
            let updatedAt = cd.updatedAt
        else { return nil }
        
        self.init(
            id: id,
            name: name,
            imageURL: imageURL,
            isActive: cd.isActive,
            createdAt: ISO8601.shared.string(from: createdAt),
            updatedAt: ISO8601.shared.string(from: updatedAt)
        )
    }
}

// MARK: - Private helpers

/// Вспомогательный форматтер для преобразования дат в ISO 8601 с долями секунды.
/// Используется для приведения формата дат в доменном слое к единому виду.
private enum ISO8601 {
    static let shared: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()
}
