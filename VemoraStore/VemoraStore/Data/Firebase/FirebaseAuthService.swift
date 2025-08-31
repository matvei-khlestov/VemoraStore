//
//  FirebaseAuthService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

final class FirebaseAuthService: AuthServiceProtocol {
    private let isAuthorizedSubject = CurrentValueSubject<Bool, Never>(false)
    var isAuthorizedPublisher: AnyPublisher<Bool, Never> {
        isAuthorizedSubject.eraseToAnyPublisher()
    }
    
    private(set) var currentUserId: String? = nil
    
    func signIn(email: String, password: String) async throws {
        // Заглушка: эмулируем успешный логин
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 сек для реалистичности
        currentUserId = UUID().uuidString
        isAuthorizedSubject.send(true)
    }
    
    func signUp(email: String, password: String) async throws {
        // Заглушка: эмулируем успешную регистрацию
        try await Task.sleep(nanoseconds: 500_000_000)
        currentUserId = UUID().uuidString
        isAuthorizedSubject.send(true)
    }
    
    func signOut() throws {
        // Заглушка: эмулируем выход
        currentUserId = nil
        isAuthorizedSubject.send(false)
    }
}
