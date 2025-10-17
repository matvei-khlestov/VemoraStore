//
//  ProfileLocalStore.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import Combine

/// Протокол `ProfileLocalStore`
///
/// Определяет интерфейс для **локального хранения профиля пользователя**
/// с поддержкой реактивных обновлений и синхронизации с удалённым источником.
///
/// Основные задачи:
/// - хранение и обновление данных профиля (`upsertProfile`);
/// - предоставление реактивных изменений состояния (`observeProfile`);
/// - очистка данных при выходе пользователя (`clear`).
///
/// Используется в:
/// - `ProfileRepository` для объединения локального и удалённого источников данных (`ProfileCollectingProtocol`);

protocol ProfileLocalStore: AnyObject {
    
    /// Наблюдает за изменениями профиля пользователя.
    /// - Parameter userId: Идентификатор пользователя.
    /// - Returns: Паблишер, эмитирующий `UserProfile?` при изменениях.
    func observeProfile(userId: String) -> AnyPublisher<UserProfile?, Never>
    
    /// Добавляет или обновляет профиль пользователя в локальном хранилище.
    /// - Parameter dto: DTO с данными профиля.
    func upsertProfile(_ dto: ProfileDTO)
    
    /// Очищает локальные данные профиля пользователя.
    /// - Parameter userId: Идентификатор пользователя.
    func clear(userId: String)
}
