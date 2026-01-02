//
//  AuthCoordinatingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import Foundation

/// Координатор модуля аутентификации.
/// Отвечает за навигацию между экранами входа, регистрации и восстановления пароля.
/// Используется для изоляции навигационной логики от контроллеров.

protocol AuthCoordinatingProtocol: Coordinator {
    
    /// Запускает модуль аутентификации.
    func start()
    
    /// Колбэк, вызываемый после завершения работы координатора (например, при успешном входе).
    var onFinish: (() -> Void)? { get set }
}
