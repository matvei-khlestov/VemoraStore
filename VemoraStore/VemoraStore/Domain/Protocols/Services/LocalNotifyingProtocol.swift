//
//  LocalNotifyingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.10.2025.
//

import Foundation
import UserNotifications

/// Протокол `LocalNotifyingProtocol`
///
/// Определяет интерфейс для работы с локальными уведомлениями в приложении.
/// Реализуется сервисом, который инкапсулирует `UNUserNotificationCenter`
/// и предоставляет удобный API для запроса разрешений, планирования и отмены уведомлений.
///
/// Основные задачи:
/// - запрос разрешений на уведомления у пользователя;
/// - регистрация пользовательских категорий (`UNNotificationCategory`);
/// - планирование одноразовых и повторяющихся уведомлений;
/// - отмена конкретных уведомлений или всех сразу;
/// - обработка действий пользователя через callback `onAction`.
///
/// Используется в:
/// - сервисах напоминаний и уведомлений о событиях;
/// - модулях, где требуется локальное напоминание (например, "заказ доставлен", "скидка", "промо").
///
/// Все методы абстрагируют работу с `UNUserNotificationCenter`,
/// что упрощает тестирование и изоляцию логики уведомлений.

public protocol LocalNotifyingProtocol: AnyObject {
    
    // MARK: - Setup
    
    /// Запрашивает у пользователя разрешение на отправку уведомлений.
    /// - Parameters:
    ///   - options: Типы уведомлений (звук, баннер, бейджи и т.д.).
    ///   - completion: Колбэк с результатом (разрешено или нет).
    func requestAuthorization(
        options: UNAuthorizationOptions,
        completion: ((Bool) -> Void)?
    )
    
    /// Регистрирует категории уведомлений (для интерактивных действий).
    /// - Parameter categories: Набор категорий `UNNotificationCategory`.
    func registerCategories(_ categories: Set<UNNotificationCategory>)
    
    /// Получает текущие настройки уведомлений пользователя.
    /// - Parameter completion: Колбэк с объектом `UNNotificationSettings`.
    func getSettings(_ completion: @escaping (UNNotificationSettings) -> Void)

    // MARK: - Schedule
    
    /// Планирует уведомление на указанное время.
    /// - Parameters:
    ///   - id: Уникальный идентификатор уведомления.
    ///   - title: Заголовок уведомления.
    ///   - body: Текст уведомления.
    ///   - date: Дата и время показа.
    ///   - categoryId: Идентификатор категории (опционально).
    ///   - userInfo: Дополнительные данные.
    ///   - unique: Если `true`, дублирующее уведомление с тем же `id` будет заменено.
    /// - Returns: Идентификатор уведомления.
    @discardableResult
    func schedule(
        id: String,
        title: String,
        body: String,
        at date: Date,
        categoryId: String?,
        userInfo: [AnyHashable: Any]?,
        unique: Bool
    ) -> String

    /// Планирует уведомление через указанное количество секунд.
    /// - Parameters:
    ///   - seconds: Задержка перед показом.
    ///   - id: Уникальный идентификатор.
    ///   - title: Заголовок.
    ///   - body: Текст уведомления.
    ///   - categoryId: Идентификатор категории (опционально).
    ///   - userInfo: Дополнительные данные.
    ///   - unique: Если `true`, старое уведомление с тем же `id` будет заменено.
    /// - Returns: Идентификатор уведомления.
    @discardableResult
    func schedule(
        after seconds: TimeInterval,
        id: String,
        title: String,
        body: String,
        categoryId: String?,
        userInfo: [AnyHashable: Any]?,
        unique: Bool
    ) -> String

    /// Планирует еженедельное повторяющееся уведомление.
    ///
    /// - Parameters:
    ///   - weekday: День недели (`1` — воскресенье, `7` — суббота, в зависимости от календаря).
    ///   - hour: Час показа уведомления.
    ///   - minute: Минута показа уведомления.
    ///   - id: Уникальный идентификатор уведомления.
    ///   - title: Заголовок уведомления.
    ///   - body: Текст уведомления.
    ///   - categoryId: Идентификатор категории (опционально).
    ///   - userInfo: Дополнительные данные.
    ///   - unique: Если `true`, уведомление заменяет предыдущее с тем же `id`.
    /// - Returns: Идентификатор уведомления.
    @discardableResult
    func scheduleWeekly(
        weekday: Int,
        hour: Int,
        minute: Int,
        id: String,
        title: String,
        body: String,
        categoryId: String?,
        userInfo: [AnyHashable: Any]?,
        unique: Bool
    ) -> String

    // MARK: - Cancel
    
    /// Отменяет запланированные уведомления по их идентификаторам.
    /// - Parameter ids: Массив идентификаторов уведомлений.
    func cancel(ids: [String])
    
    /// Отменяет все запланированные уведомления.
    func cancelAll()

    // MARK: - Delegate hook
    
    /// Колбэк, вызываемый при взаимодействии пользователя с уведомлением.
    /// Передаёт объект `UNNotificationResponse`.
    var onAction: ((UNNotificationResponse) -> Void)? { get set }
}
