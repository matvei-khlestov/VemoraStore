//
//  FavoritesFRCPublisher.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.10.2025.
//

import CoreData
import Combine

/// Класс `FavoritesFRCPublisher`
///
/// Реализует реактивное наблюдение за локальными данными избранных товаров (`CDFavoriteItem`) в Core Data.
///
/// Основные задачи:
/// - выполняет выборку избранных товаров по идентификатору пользователя (`userId`);
/// - автоматически реагирует на изменения данных через `NSFetchedResultsController`;
/// - публикует обновлённое состояние в виде Combine-потока `AnyPublisher<[FavoriteItem], Never>`.
///
/// Используется в:
/// - `FavoritesLocalStore` — как источник реактивных обновлений для слоя репозитория.

final class FavoritesFRCPublisher: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Private Properties
    
    /// Combine-паблишер для публикации текущего состояния избранных товаров.
    private let subject = CurrentValueSubject<[FavoriteItem], Never>([])
    
    /// Контроллер выборки Core Data, отслеживающий изменения сущностей `CDFavoriteItem`.
    private let frc: NSFetchedResultsController<CDFavoriteItem>
    
    // MARK: - Init
    
    /// Инициализация `FavoritesFRCPublisher`.
    /// - Parameters:
    ///   - context: Контекст Core Data, используемый для выборки.
    ///   - userId: Идентификатор пользователя, чьи избранные товары нужно отслеживать.
    init(context: NSManagedObjectContext, userId: String) {
        let req: NSFetchRequest<CDFavoriteItem> = CDFavoriteItem.fetchRequest()
        req.predicate = NSPredicate(format: "userId == %@", userId)
        req.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        
        self.frc = NSFetchedResultsController(
            fetchRequest: req,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        frc.delegate = self
        
        context.perform { [weak self] in
            guard let self else { return }
            try? self.frc.performFetch()
            let items = (self.frc.fetchedObjects ?? []).compactMap(FavoriteItem.init(cd:))
            self.subject.send(items)
        }
    }
    
    // MARK: - Deinit
    
    deinit {
        frc.delegate = nil
    }
    
    // MARK: - Public API
    
    /// Возвращает Combine-паблишер, публикующий массив избранных товаров.
    func publisher() -> AnyPublisher<[FavoriteItem], Never> {
        subject.eraseToAnyPublisher()
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    /// Метод делегата, вызываемый при изменении содержимого `NSFetchedResultsController`.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let objs = controller.fetchedObjects as? [CDFavoriteItem] ?? []
        subject.send(objs.compactMap(FavoriteItem.init(cd:)))
    }
}
