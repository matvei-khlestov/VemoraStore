//
//  ProfileRepository.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import Foundation
import Combine

protocol ProfileRepository: AnyObject {
    func observeProfile() -> AnyPublisher<UserProfile?, Never>
    func refresh(uid: String) async throws
    func ensureInitialProfile(uid: String, name: String, email: String) async throws
    func updateName(uid: String, name: String) async throws
    func updateEmail(uid: String, email: String) async throws
    func updatePhone(uid: String, phone: String) async throws
}
