//
//  AuthServiceProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

protocol AuthServiceProtocol {
    var isAuthorizedPublisher: AnyPublisher<Bool, Never> { get }
    func signIn(email: String, password: String) async throws
    func signUp(email: String, password: String) async throws
    func signOut() async throws
    func deleteAccount() async throws
    var currentUserId: String? { get }
}
