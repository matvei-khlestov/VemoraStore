//
//  ProfileRepository.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import Foundation
import Combine

/// Протокол `ProfileRepository`
///
/// Определяет единый интерфейс для управления профилем пользователя,
/// объединяя локальное (`ProfileLocalStore`) и удалённое (`ProfileCollectingProtocol`)
/// хранилища данных.
///
/// Основные задачи:
/// - реактивное наблюдение за состоянием профиля (`observeProfile`);
/// - синхронизация данных между сервером и локальным хранилищем (`refresh`);
/// - инициализация профиля при первой регистрации (`ensureInitialProfile`);
/// - обновление данных пользователя — имени, e-mail и телефона.
///
/// Используется в:
/// - `ProfileUserViewModel` — для отображения и обновления данных профиля;
/// - `EditProfileViewModel`, `EditNameViewModel`, `EditEmailViewModel`, `EditPhoneViewModel`
///   — для редактирования отдельных полей профиля.
///
/// Репозиторий скрывает источник данных и обеспечивает согласованность профиля
/// между локальной и удалённой копиями через Combine и async/await.

protocol ProfileRepository: AnyObject {
    
    // MARK: - Streams
    
    /// Наблюдает за локальным состоянием профиля пользователя.
    /// - Returns: Паблишер, эмитирующий объект `UserProfile?` при изменениях.
    func observeProfile() -> AnyPublisher<UserProfile?, Never>
    
    // MARK: - Commands
    
    /// Выполняет обновление профиля из удалённого источника
    /// и синхронизирует локальные данные.
    /// - Parameter uid: Уникальный идентификатор пользователя.
    func refresh(uid: String) async throws
    
    /// Создаёт профиль пользователя при первой регистрации или входе.
    /// - Parameters:
    ///   - uid: Уникальный идентификатор пользователя.
    ///   - name: Имя пользователя.
    ///   - email: Адрес электронной почты.
    func ensureInitialProfile(uid: String, name: String, email: String) async throws
    
    /// Обновляет имя пользователя.
    /// - Parameters:
    ///   - uid: Идентификатор пользователя.
    ///   - name: Новое имя.
    func updateName(uid: String, name: String) async throws
    
    /// Обновляет адрес электронной почты пользователя.
    /// - Parameters:
    ///   - uid: Идентификатор пользователя.
    ///   - email: Новый e-mail.
    func updateEmail(uid: String, email: String) async throws
    
    /// Обновляет номер телефона пользователя.
    /// - Parameters:
    ///   - uid: Идентификатор пользователя.
    ///   - phone: Новый номер телефона.
    func updatePhone(uid: String, phone: String) async throws
}
