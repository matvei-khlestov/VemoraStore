//
//  NotificationServiceProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation

protocol NotificationServiceProtocol {
    func updateFCMToken(_ token: String, for uid: String)
}
