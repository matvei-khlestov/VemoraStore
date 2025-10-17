//
//  EditNameCoordinatingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Foundation

/// Протокол координатора экрана изменения имени пользователя.
///
/// Определяет контракт для навигации при редактировании имени пользователя.
/// Используется для управления жизненным циклом экрана и возврата к предыдущему флоу
/// после успешного завершения редактирования.

protocol EditNameCoordinatingProtocol: Coordinator {
    
    /// Замыкание, вызываемое при завершении редактирования имени.
    var onFinish: (() -> Void)? { get set }
}
