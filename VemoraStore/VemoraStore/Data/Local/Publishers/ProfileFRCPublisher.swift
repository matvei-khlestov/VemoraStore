//
//  ProfileFRCPublisher.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import CoreData
import Combine

/// Класс `ProfileFRCPublisher` — это обёртка над `NSFetchedResultsController`,
/// предоставляющая Combine-паблишер для наблюдения за изменениями профиля пользователя в Core Data.
///
/// Используется для:
/// - получения актуальных данных профиля пользователя из локального хранилища;
/// - автоматического обновления UI при изменении данных в Core Data;
/// - интеграции реактивного потока (`AnyPublisher<UserProfile?, Never>`) с Combine.
///
/// Реализует делегат `NSFetchedResultsControllerDelegate` для отслеживания изменений данных.

final class ProfileFRCPublisher: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Output
    
    /// Паблишер, который передаёт текущее состояние профиля пользователя.
    private let subject = CurrentValueSubject<UserProfile?, Never>(nil)
    
    /// Возвращает Combine-поток с профилем пользователя.
    func publisher() -> AnyPublisher<UserProfile?, Never> { subject.eraseToAnyPublisher() }
    
    // MARK: - FRC
    
    /// Контроллер выборки для отслеживания изменений объекта `CDProfile` в Core Data.
    private let frc: NSFetchedResultsController<CDProfile>
    
    // MARK: - Init
    
    /// Инициализирует паблишер и выполняет начальную выборку данных профиля пользователя.
    ///
    /// - Parameters:
    ///   - context: Контекст `NSManagedObjectContext`, из которого будет производиться выборка.
    ///   - userId: Идентификатор пользователя, чей профиль необходимо отслеживать.
    init(context: NSManagedObjectContext, userId: String) {
        let req: NSFetchRequest<CDProfile> = CDProfile.fetchRequest()
        req.predicate = NSPredicate(format: "userId == %@", userId)
        req.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        req.fetchLimit = 1
        
        self.frc = NSFetchedResultsController(
            fetchRequest: req,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        
        frc.delegate = self
        
        // Гарантирует выполнение выборки на корректной очереди контекста
        context.perform { [weak self] in
            guard let self else { return }
            do {
                try self.frc.performFetch()
                self.subject.send(UserProfile(cd: self.frc.fetchedObjects?.first))
            } catch {
                self.subject.send(nil)
            }
        }
    }
    
    deinit {
        frc.delegate = nil
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    /// Обрабатывает изменения данных профиля в Core Data и обновляет паблишер.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let objects = controller.fetchedObjects as? [CDProfile]
        subject.send(UserProfile(cd: objects?.first))
    }
}
