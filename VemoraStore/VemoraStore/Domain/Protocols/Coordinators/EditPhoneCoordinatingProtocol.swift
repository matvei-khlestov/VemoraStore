//
//  EditPhoneCoordinatingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Foundation

/// Протокол координатора экрана изменения номера телефона.
///
/// Определяет контракт для навигации при редактировании телефонного номера пользователя.
/// Используется для управления жизненным циклом экрана и возврата к предыдущему флоу
/// после завершения редактирования.
protocol EditPhoneCoordinatingProtocol: Coordinator {
    
    /// Замыкание, вызываемое при завершении редактирования телефона.
    var onFinish: (() -> Void)? { get set }
}
