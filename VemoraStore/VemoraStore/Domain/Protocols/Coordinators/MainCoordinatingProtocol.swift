//
//  MainCoordinatingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import Foundation

/// Протокол координатора главного модуля приложения.
///
/// `MainCoordinatingProtocol` определяет контракт для основного потока приложения
/// после успешной авторизации пользователя. Он управляет переходами между экранами
/// и обработкой ключевых событий, таких как выход из аккаунта, удаление профиля
/// или успешное оформление заказа.
///
/// ## Основные задачи:
/// - Управление навигацией внутри главного флоу.
/// - Обработка сценариев выхода (`onLogout`) и удаления аккаунта (`onDeleteAccount`).
/// - Переход на экран успешного заказа (`onOrderSuccess`).
///
/// Этот протокол реализуется `MainCoordinator`, который отвечает за
/// инициализацию и отображение основных экранов приложения.

protocol MainCoordinatingProtocol: Coordinator {
    var onDeleteAccount: (() -> Void)? { get set }
    var onLogout: (() -> Void)? { get set }
    var onOrderSuccess: (() -> Void)? { get set }
}
