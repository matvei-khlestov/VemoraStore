//
//  SignInViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 21.09.2025.
//

import Foundation
import Combine

/// Протокол ViewModel для экрана входа в систему.
///
/// Отвечает за валидацию полей, управление состоянием кнопки входа и выполнение авторизации.
protocol SignInViewModelProtocol: AnyObject {
    
    // MARK: - Inputs
    
    /// Устанавливает значение e-mail.
    func setEmail(_ value: String)
    
    /// Устанавливает значение пароля.
    func setPassword(_ value: String)
    
    
    // MARK: - Outputs
    
    /// Паблишер ошибки e-mail (nil, если поле валидно).
    var emailError: AnyPublisher<String?, Never> { get }
    
    /// Паблишер ошибки пароля (nil, если поле валидно).
    var passwordError: AnyPublisher<String?, Never> { get }
    
    /// Паблишер состояния кнопки входа (активна, если данные валидны).
    var isSubmitEnabled: AnyPublisher<Bool, Never> { get }
    
    
    // MARK: - Actions
    
    /// Выполняет вход пользователя по e-mail и паролю.
    func signIn() async throws
}
