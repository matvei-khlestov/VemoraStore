//
//  LocalStore.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import Combine

protocol LocalStore: AnyObject {
    func observeProfile(userId: String) -> AnyPublisher<UserProfile?, Never>
    func upsertProfile(_ dto: ProfileDTO)
}
