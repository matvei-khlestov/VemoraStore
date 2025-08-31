//
//  ProfileServiceProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

protocol ProfileServiceProtocol {
    func loadProfile(uid: String) -> AnyPublisher<Profile, Error>
    func updateProfile(_ profile: Profile, avatar: Data?) async throws
}
