//
//  OrdersFRCPublisher.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//

import Foundation
import CoreData
import Combine

/// Класс `OrdersFRCPublisher`
///
/// Отвечает за реактивное наблюдение за сущностями заказов (`CDOrder`) в Core Data,
/// предоставляя обновления в виде Combine-паблишера (`AnyPublisher<[OrderEntity], Never>`).
///
/// Основные задачи:
/// - Выполняет выборку заказов по `userId` через `NSFetchedResultsController`;
/// - Реагирует на изменения данных (добавление, обновление, удаление);
/// - Преобразует Core Data сущности в доменные модели `OrderEntity` для слоя бизнес-логики.
///
/// Используется в:
/// - `OrdersLocalStore` — как источник реактивных данных о заказах пользователя.

final class OrdersFRCPublisher: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Private Properties
    
    /// Паблишер для отправки актуального состояния заказов.
    private let subject = CurrentValueSubject<[OrderEntity], Never>([])
    
    /// Контроллер выборки Core Data, отслеживающий изменения заказов.
    private let frc: NSFetchedResultsController<CDOrder>
    
    // MARK: - Init
    
    /// Инициализация `OrdersFRCPublisher`.
    /// - Parameters:
    ///   - context: Контекст Core Data, в котором выполняется выборка.
    ///   - userId: Идентификатор пользователя, по которому фильтруются заказы.
    init(context: NSManagedObjectContext, userId: String) {
        let req: NSFetchRequest<CDOrder> = CDOrder.fetchRequest()
        req.predicate = NSPredicate(format: "userId == %@", userId)
        req.sortDescriptors = [
            NSSortDescriptor(key: "createdAt", ascending: false)
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
                let entities = (self.frc.fetchedObjects ?? []).compactMap { OrderEntity(cd: $0) }
                self.subject.send(entities)
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
    
    /// Возвращает Combine-паблишер, публикующий массив заказов.
    func publisher() -> AnyPublisher<[OrderEntity], Never> {
        subject.eraseToAnyPublisher()
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    /// Метод делегата, вызываемый при изменении содержимого контроллера выборки.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let objs = controller.fetchedObjects as? [CDOrder] ?? []
        subject.send(objs.compactMap { OrderEntity(cd: $0) })
    }
}
