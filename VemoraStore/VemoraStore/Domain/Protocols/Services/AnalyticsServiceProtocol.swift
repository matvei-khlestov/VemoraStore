//
//  AnalyticsServiceProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 07.01.2026.
//

import Foundation

protocol AnalyticsServiceProtocol {
    func log(_ event: AnalyticsEvent)
    func setUserId(_ userId: String?)
    func setUserProperty(_ value: String?, forName name: String)
}
