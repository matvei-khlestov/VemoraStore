//
//  EditProfileViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import Foundation
import Combine

/// Протокол ViewModel для экрана редактирования профиля.
///
/// Отвечает за предоставление и обновление данных пользователя,
/// а также за загрузку и сохранение аватара.
/// Обеспечивает реактивное обновление интерфейса через Combine.

protocol EditProfileViewModelProtocol {
    
    // MARK: - Outputs
    
    /// Имя пользователя.
    var name: String { get }
    
    /// Электронная почта пользователя.
    var email: String { get }
    
    /// Номер телефона пользователя.
    var phone: String { get }
    
    /// Паблишер имени пользователя.
    var namePublisher: AnyPublisher<String, Never> { get }
    
    /// Паблишер электронной почты пользователя.
    var emailPublisher: AnyPublisher<String, Never> { get }
    
    /// Паблишер номера телефона пользователя.
    var phonePublisher: AnyPublisher<String, Never> { get }
    
    /// Паблишер данных аватара пользователя.
    var avatarDataPublisher: AnyPublisher<Data?, Never> { get }
    
    // MARK: - Actions
    
    /// Загружает данные аватара пользователя из локального хранилища.
    func loadAvatarData()
    
    /// Сохраняет данные аватара пользователя в локальное хранилище.
    func saveAvatarData(_ data: Data) async throws
}
