//
//  ScreenFactoryProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import UIKit

/// Протокол `ScreenFactoryProtocol`
///
/// Используется преимущественно в **UI-тестах** и интеграционных сценариях
/// для централизованного создания экранов приложения.
///
/// Основные задачи:
/// - фабричное создание экземпляров `UIViewController` без прямой зависимости от координаторов;
/// - упрощение мокирования экранов и проверки их конфигурации в UI-тестах;
/// - единая точка сборки экранов профиля и аутентификации.
///
/// Применяется:
/// - в `AuthCoordinator` и `ProfileCoordinator` при запуске flow;
/// - в UI-тестах для быстрой инициализации экранов без участия навигации.

protocol ScreenFactoryProtocol {
    
    /// Создаёт экран входа (`SignInViewController`).
    func makeSignInViewController() -> UIViewController
    
    /// Создаёт экран регистрации (`SignUpViewController`).
    func makeSignUpViewController() -> UIViewController
    
    /// Создаёт экран профиля пользователя (`ProfileUserViewController`).
    /// - Parameter userId: Идентификатор пользователя.
    func makeProfileUserViewController(userId: String) -> UIViewController
    
    /// Создаёт экран редактирования профиля (`EditProfileViewController`).
    /// - Parameter userId: Идентификатор пользователя.
    func makeEditProfileViewController(userId: String) -> UIViewController
    
    /// Создаёт экран изменения имени (`EditNameViewController`).
    /// - Parameter userId: Идентификатор пользователя.
    func makeEditNameViewController(userId: String) -> UIViewController
    
    /// Создаёт экран изменения email (`EditEmailViewController`).
    /// - Parameter userId: Идентификатор пользователя.
    func makeEditEmailViewController(userId: String) -> UIViewController
    
    /// Создаёт экран изменения телефона (`EditPhoneViewController`).
    /// - Parameter userId: Идентификатор пользователя.
    func makeEditPhoneViewController(userId: String) -> UIViewController
}
