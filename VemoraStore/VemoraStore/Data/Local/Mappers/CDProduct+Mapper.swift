//
//  CDProduct+Mapper.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 06.10.2025.
//

import CoreData

import CoreData

/// Расширение `CDProduct`, реализующее маппинг между Core Data и Domain слоями.
///
/// Отвечает за преобразование данных между `ProductDTO` (сетевой моделью)
/// и `CDProduct` (локальной моделью Core Data), а также за построение
/// доменной модели `Product` из Core Data сущности.
///
/// Используется в:
/// - `CatalogLocalStore` и `CatalogRepository`
/// для синхронизации каталога товаров между сервером и локальным хранилищем.
extension CDProduct {
    
    /// Применяет данные из `ProductDTO` к Core Data сущности `CDProduct`.
    /// - Parameter dto: DTO товара, полученный из API.
    func apply(dto: ProductDTO) {
        id         = dto.id
        name       = dto.name
        desc       = dto.description
        nameLower  = dto.nameLower
        categoryId = dto.categoryId
        brandId    = dto.brandId
        price      = dto.price
        imageURL   = dto.imageURL
        isActive   = dto.isActive
        createdAt  = dto.createdAt
        updatedAt  = dto.updatedAt
        keywords   = dto.keywords
        
        // Индекс для полнотекстового поиска (имя + ключевые слова в нижнем регистре)
        keywordsIndex = ([dto.nameLower] + dto.keywords.map { $0.lowercased() })
            .joined(separator: " ")
    }
    
    /// Проверяет совпадение полей сущности с переданным DTO.
    /// Используется для предотвращения избыточных обновлений.
    /// - Parameter dto: DTO для сравнения.
    /// - Returns: `true`, если все поля идентичны.
    func matches(_ dto: ProductDTO) -> Bool {
        (id ?? "") == dto.id &&
        (name ?? "") == dto.name &&
        (desc ?? "") == dto.description &&
        (nameLower ?? "") == dto.nameLower &&
        (categoryId ?? "") == dto.categoryId &&
        (brandId ?? "") == dto.brandId &&
        price == dto.price &&
        (imageURL ?? "") == dto.imageURL &&
        isActive == dto.isActive &&
        (createdAt ?? .distantPast) == dto.createdAt &&
        (updatedAt ?? .distantPast) == dto.updatedAt &&
        (keywords ?? []) == dto.keywords &&
        (keywordsIndex ?? "") == (([dto.nameLower] + dto.keywords.map {
            $0.lowercased()
        }).joined(separator: " "))
    }
}

/// Расширение `Product`, предоставляющее инициализацию
/// доменной модели на основе Core Data сущности `CDProduct`.
///
/// Выполняет безопасное извлечение данных и конвертацию дат
/// в ISO 8601 формат для унификации представления в Domain-слое.
extension Product {
    
    /// Инициализирует доменную модель `Product` из Core Data сущности `CDProduct`.
    /// - Parameter cd: Core Data объект `CDProduct`.
    init?(cd: CDProduct?) {
        guard let cd,
              let id = cd.id,
              let name = cd.name,
              let desc = cd.desc,
              let nameLower = cd.nameLower,
              let categoryId = cd.categoryId,
              let brandId = cd.brandId,
              let imageURL = cd.imageURL,
              let createdAt = cd.createdAt,
              let updatedAt = cd.updatedAt
        else { return nil }
        
        self.init(
            id: id,
            name: name,
            description: desc,
            nameLower: nameLower,
            categoryId: categoryId,
            brandId: brandId,
            price: cd.price,
            imageURL: imageURL,
            isActive: cd.isActive,
            createdAt: ISO8601.shared.string(from: createdAt),
            updatedAt: ISO8601.shared.string(from: updatedAt),
            keywords: cd.keywords ?? []
        )
    }
}

// MARK: - Private helpers

/// Вспомогательный форматтер для приведения дат к ISO 8601 формату.
/// Используется для сериализации временных меток в доменных моделях.
private enum ISO8601 {
    static let shared: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        return f
    }()
}
