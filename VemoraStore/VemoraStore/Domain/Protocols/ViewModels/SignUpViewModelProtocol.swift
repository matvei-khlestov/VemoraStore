//
//  SignUpViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 19.09.2025.
//

import Foundation
import Combine

/// Протокол `SignUpViewModelProtocol` описывает контракт ViewModel
/// для экрана регистрации пользователя.
///
/// Отвечает за:
/// - приём и валидацию пользовательских данных (имя, e-mail, пароль);
/// - контроль согласия с политикой конфиденциальности;
/// - реактивное обновление ошибок валидации и доступности кнопки регистрации;
/// - выполнение асинхронной регистрации пользователя.
///
/// Особенности:
/// - все ошибки и состояния обновляются реактивно через Combine;
/// - метод `signUp()` асинхронно выполняет регистрацию и проверяет корректность всех данных;
/// - подходит для биндинга с `SignUpViewController`.

protocol SignUpViewModelProtocol: AnyObject {
    
    // MARK: - Inputs
    
    /// Устанавливает имя пользователя.
    func setName(_ value: String)
    
    /// Устанавливает e-mail пользователя.
    func setEmail(_ value: String)
    
    /// Устанавливает пароль пользователя.
    func setPassword(_ value: String)
    
    /// Устанавливает состояние согласия с политикой конфиденциальности.
    func setAgreement(_ value: Bool)
    
    // MARK: - Outputs
    
    /// Ошибка валидации имени.
    var nameError: AnyPublisher<String?, Never> { get }
    
    /// Ошибка валидации e-mail.
    var emailError: AnyPublisher<String?, Never> { get }
    
    /// Ошибка валидации пароля.
    var passwordError: AnyPublisher<String?, Never> { get }
    
    /// Ошибка согласия с политикой конфиденциальности.
    var agreementError: AnyPublisher<String?, Never> { get }
    
    /// Флаг, разрешающий активацию кнопки регистрации.
    var isSubmitEnabled: AnyPublisher<Bool, Never> { get }
    
    // MARK: - Actions
    
    /// Выполняет регистрацию нового пользователя с проверкой всех введённых данных.
    func signUp() async throws
}
