//
//  CartFRCPublisher.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 11.10.2025.
//

import CoreData
import Combine

/// Класс `CartFRCPublisher`
///
/// Реализует реактивное наблюдение за локальными данными корзины (`CDCartItem`) в Core Data.
/// Обеспечивает автоматическое обновление данных при любых изменениях в хранилище.
///
/// Основные задачи:
/// - выполняет выборку товаров корзины по `userId`;
/// - наблюдает за изменениями данных через `NSFetchedResultsController`;
/// - публикует актуальные данные корзины как Combine-поток `AnyPublisher<[CartItem], Never>`.
///
/// Используется в:
/// - `CartLocalStore` — как источник реактивных данных для слоя репозитория.

final class CartFRCPublisher: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Private Properties
    
    /// Паблишер, предоставляющий актуальное состояние корзины.
    private let subject = CurrentValueSubject<[CartItem], Never>([])
    
    /// Контроллер выборки Core Data, отслеживающий изменения корзины.
    private let frc: NSFetchedResultsController<CDCartItem>
    
    // MARK: - Init
    
    /// Инициализация `CartFRCPublisher`.
    /// - Parameters:
    ///   - context: Контекст Core Data для выборки данных.
    ///   - userId: Идентификатор пользователя, чья корзина отслеживается.
    init(context: NSManagedObjectContext, userId: String) {
        let req: NSFetchRequest<CDCartItem> = CDCartItem.fetchRequest()
        req.predicate = NSPredicate(format: "userId == %@", userId)
        req.sortDescriptors = [
            NSSortDescriptor(key: "productId", ascending: true)
        ]
        
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
            do {
                try self.frc.performFetch()
                let items = (self.frc.fetchedObjects ?? []).compactMap { CartItem(cd: $0) }
                self.subject.send(items)
            } catch {
                self.subject.send([])
            }
        }
    }
    
    // MARK: - Deinit
    
    deinit {
        frc.delegate = nil
    }
    
    // MARK: - Public API
    
    /// Возвращает Combine-паблишер, публикующий массив элементов корзины.
    func publisher() -> AnyPublisher<[CartItem], Never> {
        subject.eraseToAnyPublisher()
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    /// Делегатный метод, вызываемый при изменении содержимого `NSFetchedResultsController`.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let objs = controller.fetchedObjects as? [CDCartItem] ?? []
        subject.send(objs.compactMap { CartItem(cd: $0) })
    }
}
