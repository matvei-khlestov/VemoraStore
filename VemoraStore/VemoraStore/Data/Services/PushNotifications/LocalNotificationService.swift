//
//  LocalNotificationService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.10.2025.
//

import Foundation
import UserNotifications

// MARK: - Categories

public enum NotificationCategoryId {
    public static let favorites  = "favorites.category"
    public static let cart = "cart.category"
    public static let checkout = "checkout.category"
}

public enum NotificationActionId {
    public static let favOpen = "favorites.open"
    public static let cartOpen = "cart.open"
    public static let checkoutOpen = "checkout.open"
}

// MARK: - Service

public final class LocalNotificationService: NSObject, LocalNotifyingProtocol {
    
    public static let shared = LocalNotificationService()
    
    public var onAction: ((UNNotificationResponse) -> Void)?
    
    private let center: UNUserNotificationCenter
    private let calendar: Calendar
    
    public init(center: UNUserNotificationCenter = .current(),
                calendar: Calendar = .current) {
        self.center = center
        self.calendar = calendar
        super.init()
        center.delegate = self
    }
    
    // MARK: Setup
    
    public func requestAuthorization(options: UNAuthorizationOptions = [.alert, .badge, .sound],
                                     completion: ((Bool) -> Void)? = nil) {
        center.requestAuthorization(options: options) { granted, _ in
            completion?(granted)
        }
    }
    
    public func registerCategories(_ categories: Set<UNNotificationCategory>) {
        center.setNotificationCategories(categories)
    }
    
    public func getSettings(_ completion: @escaping (UNNotificationSettings) -> Void) {
        center.getNotificationSettings(completionHandler: completion)
    }
    
    // MARK: Schedule (date)
    
    @discardableResult
    public func schedule(id: String = UUID().uuidString,
                         title: String,
                         body: String,
                         at date: Date,
                         categoryId: String? = nil,
                         userInfo: [AnyHashable: Any]? = nil,
                         unique: Bool = true) -> String {
        
        let fireDate = max(date, Date().addingTimeInterval(1))
        
        let comps = calendar.dateComponents(
            [
                .year,
                .month,
                .day,
                .hour,
                .minute
            ],
            from: fireDate
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: comps,
            repeats: false
        )
        let content = makeContent(
            title: title,
            body: body,
            categoryId: categoryId,
            userInfo: userInfo
        )
        
        if unique {
            center.removePendingNotificationRequests(withIdentifiers: [id])
        }
        let req = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )
        center.add(req)
        return id
    }
    
    // MARK: Schedule (after seconds)
    
    @discardableResult
    public func schedule(after seconds: TimeInterval,
                         id: String = UUID().uuidString,
                         title: String,
                         body: String,
                         categoryId: String? = nil,
                         userInfo: [AnyHashable: Any]? = nil,
                         unique: Bool = false) -> String {
        let t = max(1, seconds)
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: t,
            repeats: false
        )
        let content = makeContent(
            title: title,
            body: body,
            categoryId: categoryId,
            userInfo: userInfo
        )
        
        if unique {
            center.removePendingNotificationRequests(withIdentifiers: [id])
        }
        let req = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )
        center.add(req)
        return id
    }
    
    // MARK: Schedule weekly
    
    @discardableResult
    public func scheduleWeekly(weekday: Int,
                               hour: Int,
                               minute: Int,
                               id: String,
                               title: String,
                               body: String,
                               categoryId: String? = nil,
                               userInfo: [AnyHashable: Any]? = nil,
                               unique: Bool = true) -> String {
        var comps = DateComponents()
        comps.weekday = weekday
        comps.hour = hour
        comps.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: comps,
            repeats: true
        )
        let content = makeContent(
            title: title,
            body: body,
            categoryId: categoryId,
            userInfo: userInfo
        )
        
        if unique {
            center.removePendingNotificationRequests(withIdentifiers: [id])
        }
        let req = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )
        center.add(req)
        return id
    }
    
    // MARK: Cancel
    
    public func cancel(ids: [String]) {
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }
    
    public func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
    
    // MARK: Helpers
    
    private func makeContent(title: String,
                             body: String,
                             categoryId: String?,
                             userInfo: [AnyHashable: Any]?) -> UNMutableNotificationContent {
        let c = UNMutableNotificationContent()
        c.title = title
        c.body  = body
        c.sound = .default
        if let categoryId { c.categoryIdentifier = categoryId }
        if let userInfo { c.userInfo = userInfo }
        return c
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension LocalNotificationService: UNUserNotificationCenterDelegate {
    /// Показать баннер и в foreground
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        // Прокинем наверх: координатор/роутер решит, что делать
        onAction?(response)
        completionHandler()
    }
}

// MARK: - Ready-made categories you can register

public enum LocalNotificationFactory {
    /// Категория для «Избранного» без экшенов
    public static func favoritesCategory() -> UNNotificationCategory {
        return UNNotificationCategory(
            identifier: NotificationCategoryId.favorites,
            actions: [],
            intentIdentifiers: [],
            options: []
        )
    }

    /// Базовая категория для корзины без экшенов
    public static func cartCategory() -> UNNotificationCategory {
        return UNNotificationCategory(
            identifier: NotificationCategoryId.cart,
            actions: [],
            intentIdentifiers: [],
            options: []
        )
    }

    /// Категория для уведомлений о самовывозе заказа (checkout pickup) без экшенов
    public static func checkoutCategory() -> UNNotificationCategory {
        return UNNotificationCategory(
            identifier: NotificationCategoryId.checkout,
            actions: [],
            intentIdentifiers: [],
            options: []
        )
    }
}
