//
//  CDCategory+Mapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import CoreData

/// Расширение `CDCategory`, реализующее маппинг между Core Data и Domain слоями.
///
/// Отвечает за преобразование данных между `CategoryDTO` (сетевой моделью)
/// и `CDCategory` (локальной моделью Core Data), а также создание доменной модели `Category`.
///
/// Используется в:
/// - `CatalogLocalStore` и `CatalogRepository`
/// для синхронизации категорий между сервером и локальным хранилищем.
extension CDCategory {
    
    /// Применяет данные из `CategoryDTO` к Core Data сущности.
    /// - Parameter dto: DTO категории, полученный из API.
    func apply(dto: CategoryDTO) {
        id = dto.id
        name = dto.name
        imageURL = dto.imageURL
        brandIds = dto.brandIds
        isActive = dto.isActive
        createdAt = dto.createdAt
        updatedAt = dto.updatedAt
    }
    
    /// Проверяет совпадение всех полей с указанным `CategoryDTO`.
    /// Используется для предотвращения лишних обновлений.
    /// - Parameter dto: DTO для сравнения.
    /// - Returns: `true`, если все поля идентичны.
    func matches(_ dto: CategoryDTO) -> Bool {
        (id ?? "") == dto.id &&
        (name ?? "") == dto.name &&
        (imageURL ?? "") == dto.imageURL &&
        (brandIds ?? []) == dto.brandIds &&
        isActive == dto.isActive &&
        (createdAt ?? .distantPast) == dto.createdAt &&
        (updatedAt ?? .distantPast) == dto.updatedAt
    }
}

/// Расширение `Category`, предоставляющее инициализацию
/// доменной модели на основе Core Data сущности `CDCategory`.
///
/// Выполняет безопасное извлечение данных и форматирование дат
/// в ISO 8601 формат для унификации представления в Domain-слое.
extension Category {
    
    /// Инициализирует доменную модель `Category` из Core Data сущности `CDCategory`.
    /// - Parameter cd: Core Data объект `CDCategory`.
    init?(cd: CDCategory?) {
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
            brandIds: cd.brandIds ?? [],
            isActive: cd.isActive,
            createdAt: ISO8601.shared.string(from: createdAt),
            updatedAt: ISO8601.shared.string(from: updatedAt)
        )
    }
}

// MARK: - Private helpers

/// Вспомогательный форматтер для приведения дат к ISO 8601 формату.
/// Используется для сериализации временных меток в доменных моделях.
private enum ISO8601 {
    static let shared: ISO8601DateFormatter = {
        ISO8601DateFormatter()
    }()
}
