//
//  ProfileCollectingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 02.10.2025.
//

import Foundation

protocol ProfileCollectingProtocol: AnyObject {
    func ensureInitialUserProfile(uid: String, name: String, email: String) async throws
    func fetchProfile(uid: String) async throws -> ProfileDTO?
    func updateName(uid: String, name: String) async throws
    func updateEmail(uid: String, email: String) async throws
    func updatePhone(uid: String, phone: String) async throws
}
