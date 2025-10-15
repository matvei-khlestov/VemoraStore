//
//  LocalNotifyingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.10.2025.
//

import Foundation
import UserNotifications

public protocol LocalNotifyingProtocol: AnyObject {
    // Setup
    func requestAuthorization(options: UNAuthorizationOptions, completion: ((Bool) -> Void)?)
    func registerCategories(_ categories: Set<UNNotificationCategory>)
    func getSettings(_ completion: @escaping (UNNotificationSettings) -> Void)

    // Schedule
    @discardableResult
    func schedule(id: String,
                  title: String,
                  body: String,
                  at date: Date,
                  categoryId: String?,
                  userInfo: [AnyHashable: Any]?,
                  unique: Bool) -> String

    @discardableResult
    func schedule(after seconds: TimeInterval,
                  id: String,
                  title: String,
                  body: String,
                  categoryId: String?,
                  userInfo: [AnyHashable: Any]?,
                  unique: Bool) -> String

    /// Еженедельное повторение (weekday: 1=воскресенье, 7=суббота в текущем календаре)
    @discardableResult
    func scheduleWeekly(weekday: Int,
                        hour: Int,
                        minute: Int,
                        id: String,
                        title: String,
                        body: String,
                        categoryId: String?,
                        userInfo: [AnyHashable: Any]?,
                        unique: Bool) -> String

    // Cancel
    func cancel(ids: [String])
    func cancelAll()

    // Delegate hook for actions
    var onAction: ((UNNotificationResponse) -> Void)? { get set }
}

