//
//  AnalyticsServiceSpy.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 22.01.2026.
//

import Foundation
@testable import VemoraStore

final class AnalyticsServiceSpy: AnalyticsServiceProtocol {
    
    private(set) var logged: [AnalyticsEvent] = []
    private(set) var setUserIdCalls: [String?] = []
    private(set) var setUserPropertyCalls: [(value: String?, name: String)] = []
    
    func log(_ event: AnalyticsEvent) {
        logged.append(event)
    }
    
    func setUserId(_ userId: String?) {
        setUserIdCalls.append(userId)
    }
    
    func setUserProperty(_ value: String?, forName name: String) {
        setUserPropertyCalls.append((value: value, name: name))
    }
}
