//
//  EditEmailCoordinatingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Foundation

/// Протокол координатора экрана изменения адреса электронной почты.
///
/// Определяет контракт для навигации при редактировании e-mail пользователя.
/// Используется для управления жизненным циклом экрана и возврата к предыдущему флоу
/// после успешного завершения редактирования.

protocol EditEmailCoordinatingProtocol: Coordinator {
    
    /// Замыкание, вызываемое при завершении редактирования e-mail.
    var onFinish: (() -> Void)? { get set }
}
