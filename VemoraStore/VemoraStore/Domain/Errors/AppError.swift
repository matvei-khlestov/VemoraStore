//
//  AppError.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.10.2025.
//

import Foundation
import FirebaseFirestore

/// Универсальные ошибки приложения.
///
/// Используется для отображения понятных пользователю сообщений
/// при сетевых или серверных сбоях, проблемах доступа и т.д.
enum AppError: LocalizedError {
    
    // MARK: - Cases
    
    case emptyCart
    case missingRequiredFields
    case network
    case timeout
    case server
    case permission
    case unavailable
    case unknown(Error)
    
    // MARK: - Localized description
    
    var errorDescription: String? {
        switch self {
        case .emptyCart:
            return "Корзина пуста."
        case .missingRequiredFields:
            return "Укажите все обязательные данные."
        case .network:
            return "Проблема с сетью. Проверьте подключение к интернету."
        case .timeout:
            return "Превышено время ожидания. Попробуйте ещё раз."
        case .server:
            return "Ошибка сервера. Мы уже работаем над этим."
        case .permission:
            return "Недостаточно прав. Войдите заново."
        case .unavailable:
            return "Сервис временно недоступен. Попробуйте позже."
        case .unknown:
            return "Что-то пошло не так. Попробуйте позже."
        }
    }
}

// MARK: - Mapping

extension AppError {
    static func map(_ error: Error) -> AppError {
        let ns = error as NSError
        
        if ns.domain == NSURLErrorDomain {
            let urlErr = URLError.Code(rawValue: ns.code)
            switch urlErr {
            case .notConnectedToInternet,
                    .networkConnectionLost,
                    .cannotFindHost,
                    .cannotConnectToHost,
                    .dnsLookupFailed:
                return .network
            case .timedOut:
                return .timeout
            case .userAuthenticationRequired, .noPermissionsToReadFile:
                return .permission
            default:
                break
            }
        }
        
        if ns.domain == FirestoreErrorDomain,
           let code = FirestoreErrorCode.Code(rawValue: ns.code) {
            switch code {
            case .unavailable:
                return .unavailable
            case .permissionDenied:
                return .permission
            case .deadlineExceeded:
                return .timeout
            case .resourceExhausted:
                return .server
            case .internal, .unknown:
                return .server
            default:
                break
            }
        }
        
        return .unknown(error)
    }
}
