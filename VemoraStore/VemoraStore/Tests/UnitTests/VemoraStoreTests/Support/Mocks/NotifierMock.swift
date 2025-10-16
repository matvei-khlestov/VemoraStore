//
//  NotifierMock.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import Foundation
import UserNotifications
@testable import VemoraStore

final class NotifierMock: LocalNotifyingProtocol {
    
    private(set) var requestedAuth = false
    private(set) var registeredCategories: Set<UNNotificationCategory> = []
    private(set) var scheduleAtCount = 0
    private(set) var scheduleAfterCount = 0
    private(set) var scheduleWeeklyCount = 0
    private(set) var lastScheduledId: String?
    private(set) var lastScheduledAfterSeconds: TimeInterval?
    private(set) var lastScheduledDate: Date?
    private(set) var lastCancelledIds: [String] = []
    private(set) var cancelAllCalled = false

    var onAction: ((UNNotificationResponse) -> Void)?

    func requestAuthorization(options: UNAuthorizationOptions, completion: ((Bool) -> Void)?) {
        requestedAuth = true
        completion?(true)
    }

    func registerCategories(_ categories: Set<UNNotificationCategory>) {
        registeredCategories = categories
    }

    func getSettings(_ completion: @escaping (UNNotificationSettings) -> Void) {
        // UNNotificationSettings не имеет публичного инициализатора — оставляем пустую заглушку
    }

    @discardableResult
    func schedule(id: String,
                  title: String,
                  body: String,
                  at date: Date,
                  categoryId: String?,
                  userInfo: [AnyHashable : Any]?,
                  unique: Bool) -> String {
        scheduleAtCount += 1
        lastScheduledId = id
        lastScheduledDate = date
        return id
    }

    @discardableResult
    func schedule(after seconds: TimeInterval,
                  id: String,
                  title: String,
                  body: String,
                  categoryId: String?,
                  userInfo: [AnyHashable : Any]?,
                  unique: Bool) -> String {
        scheduleAfterCount += 1
        lastScheduledId = id
        lastScheduledAfterSeconds = seconds
        return id
    }

    @discardableResult
    func scheduleWeekly(weekday: Int,
                        hour: Int,
                        minute: Int,
                        id: String,
                        title: String,
                        body: String,
                        categoryId: String?,
                        userInfo: [AnyHashable : Any]?,
                        unique: Bool) -> String {
        scheduleWeeklyCount += 1
        lastScheduledId = id
        return id
    }

    func cancel(ids: [String]) {
        lastCancelledIds.append(contentsOf: ids)
    }

    func cancelAll() {
        cancelAllCalled = true
    }
}
