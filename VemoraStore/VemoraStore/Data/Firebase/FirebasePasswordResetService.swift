//
//  FirebasePasswordResetService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 21.09.2025.
//

import Foundation

/// Моковая реализация. Имитирует работу Firebase Auth.
final class FirebasePasswordResetService: PasswordResetServiceProtocol {
    
    enum ResetError: LocalizedError {
        case invalidEmail
        case network
        
        var errorDescription: String? {
            switch self {
            case .invalidEmail: 
                return "Некорректный e-mail."
            case .network:      
                return "Сеть недоступна. Повторите позже."
            }
        }
    }
    
    func sendPasswordReset(email: String) async throws {
        // имитируем задержку сети
        try await Task.sleep(nanoseconds: 600_000_000) // 0.6s
        
        // простая проверка для примера
        guard email.contains("@") else { throw ResetError.invalidEmail }
        
        // иногда «падает сеть» :)
        if Bool.random() { return } else { throw ResetError.network }
    }
}
