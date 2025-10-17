//
//  ProfileCollectingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 02.10.2025.
//

import Foundation
import Combine

/// Протокол `ProfileCollectingProtocol`
///
/// Определяет интерфейс для работы с данными **профиля пользователя**.
///
/// Основные задачи:
/// - инициализация профиля при первом входе (`ensureInitialUserProfile`);
/// - загрузка актуальных данных профиля (`fetchProfile`);
/// - обновление отдельных полей (имя, e-mail, телефон);
/// - реактивное наблюдение за изменениями профиля (`listenProfile`).
///
/// Используется в:
/// - `ProfileRepository` для абстрагирования работы с сетью или базой данных;
/// - `ProfileUserViewModel` и `EditProfileViewModel`
///   для получения и изменения данных профиля в UI.
protocol ProfileCollectingProtocol: AnyObject {
    
    /// Создаёт профиль пользователя при первом входе, если он отсутствует.
    /// - Parameters:
    ///   - uid: Уникальный идентификатор пользователя.
    ///   - name: Имя пользователя.
    ///   - email: Электронная почта пользователя.
    func ensureInitialUserProfile(uid: String, name: String, email: String) async throws
    
    /// Загружает актуальные данные профиля пользователя.
    /// - Parameter uid: Уникальный идентификатор пользователя.
    /// - Returns: Модель `ProfileDTO` или `nil`, если профиль отсутствует.
    func fetchProfile(uid: String) async throws -> ProfileDTO?
    
    /// Обновляет имя пользователя.
    /// - Parameters:
    ///   - uid: Уникальный идентификатор пользователя.
    ///   - name: Новое имя.
    func updateName(uid: String, name: String) async throws
    
    /// Обновляет адрес электронной почты пользователя.
    /// - Parameters:
    ///   - uid: Уникальный идентификатор пользователя.
    ///   - email: Новый адрес e-mail.
    func updateEmail(uid: String, email: String) async throws
    
    /// Обновляет номер телефона пользователя.
    /// - Parameters:
    ///   - uid: Уникальный идентификатор пользователя.
    ///   - phone: Новый номер телефона.
    func updatePhone(uid: String, phone: String) async throws
    
    /// Реактивно слушает изменения профиля пользователя.
    /// - Parameter uid: Уникальный идентификатор пользователя.
    /// - Returns: Паблишер, эмитирующий актуальное состояние профиля `ProfileDTO?`.
    func listenProfile(uid: String) -> AnyPublisher<ProfileDTO?, Never>
}
