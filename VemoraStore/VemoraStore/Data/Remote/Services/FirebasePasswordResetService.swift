//
//  FirebasePasswordResetService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 21.09.2025.
//

import Foundation
import FirebaseAuth

/// Сервис восстановления пароля `FirebasePasswordResetService`
/// — реализация `PasswordResetServiceProtocol` на основе Firebase Authentication.
///
/// Назначение:
/// - отправка писем для сброса пароля по указанному e-mail (`sendPasswordReset`);
/// - обработка и маппинг ошибок FirebaseAuth в человекочитаемые доменные ошибки.
///
/// Поведение:
/// - при вызове `sendPasswordReset(email:)` инициирует асинхронный запрос Firebase
///   `Auth.auth().sendPasswordReset(withEmail:)`;
/// - в случае ошибки преобразует `AuthErrorCode` в `ResetDomainError`
///   (`invalidEmail`, `userNotFound`, `tooManyRequests`, `network`, `unknown`);
/// - каждая ошибка имеет локализованное описание (`LocalizedError`), пригодное для отображения в UI.
///
/// Особенности реализации:
/// - использует `async/await` API FirebaseAuth для асинхронных операций;
/// - не требует аутентифицированного пользователя;
/// - безопасно обрабатывает неизвестные ошибки и возвращает `.unknown`;
/// - не кэширует состояние, выполняет операции напрямую через `FirebaseAuth`.

final class FirebasePasswordResetService: PasswordResetServiceProtocol {
    
    // MARK: - Public API
    
    func sendPasswordReset(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw mapFirebaseAuthError(error)
        }
    }
}

// MARK: - Error mapping

private extension FirebasePasswordResetService {
    enum ResetDomainError: LocalizedError {
        case invalidEmail
        case userNotFound
        case tooManyRequests
        case network
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .invalidEmail:
                return "Некорректный e-mail."
            case .userNotFound:
                return "Пользователь с таким e-mail не найден."
            case .tooManyRequests:
                return "Слишком много попыток. Попробуйте позже."
            case .network:
                return "Проблема с сетью."
            case .unknown:
                return "Неизвестная ошибка."
            }
        }
    }
    
    func mapFirebaseAuthError(_ error: Error) -> Error {
        let ns = error as NSError
        guard ns.domain == AuthErrorDomain,
              let code = AuthErrorCode(rawValue: ns.code) else {
            return ResetDomainError.unknown
        }
        
        switch code {
        case .invalidEmail:
            return ResetDomainError.invalidEmail
        case .userNotFound:
            return ResetDomainError.userNotFound
        case .tooManyRequests:
            return ResetDomainError.tooManyRequests
        case .networkError:
            return ResetDomainError.network
        default:
            return ResetDomainError.unknown
        }
    }
}
