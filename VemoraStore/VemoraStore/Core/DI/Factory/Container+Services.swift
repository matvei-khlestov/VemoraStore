//
//  Container+Services.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import FactoryKit

/// Расширение `Container+Services` — регистрация всех сервисов приложения
/// в DI-контейнере.
///
/// Назначение:
/// - Определяет зависимости для ключевых сервисов приложения: аутентификация,
///   безопасность, хранение данных, уведомления, работа с картами и отладка;
/// - Централизует создание и управление экземплярами сервисов;
/// - Использует `FactoryKit` для декларативной регистрации зависимостей.
///
/// Основные группы сервисов:
///
/// **Аутентификация**
/// - `authSessionStorage` — хранилище сессии пользователя (Keychain);
/// - `authService` — сервис авторизации на Firebase;
/// - `passwordResetService` — восстановление пароля.
///
/// **Безопасность**
/// - `keychainService` — обёртка над Keychain API для безопасного хранения данных.
///
/// **Профиль**
/// - `avatarStorageService` — загрузка и хранение аватаров пользователей.
///
/// **Оформление заказа**
/// - `checkoutStorage` — кэш состояния чекаута, реализованный как Singleton.
///
/// **Карты и геолокация**
/// - `addressSearchService` — поиск адресов по тексту;
/// - `geocodingService` — геокодирование через `CLGeocodingService`.
///
/// **Уведомления**
/// - `localNotificationService` — локальные уведомления (push категории и напоминания).
///
/// **Отладка (DEBUG)**
/// - `debugImportStorage` — хранилище данных для UI Debug режима;
/// - `checksumStorage` — механизм контроля целостности отладочных данных;
/// - `debugImportService` — сервис импорта отладочных сущностей;
/// - `debugImporter` — интерфейс для выполнения импортов в тестовой среде.
///
/// Особенности:
/// - Все критичные сервисы зарегистрированы как `.singleton` для гарантии единого экземпляра;
/// - Используются протоколы (`AuthServiceProtocol`, `PasswordResetServiceProtocol`,
///   `KeychainServiceProtocol`) для слабой связности и удобного мокинга;
/// - Поддерживает DEBUG-конфигурацию без влияния на production окружение.
///
/// Расширение входит в модуль **Dependency Injection Layer (Services)**
/// и обеспечивает все слои приложения базовыми системными сервисами.

extension Container {
    
    // MARK: - Auth
    
    var authSessionStorage: Factory<AuthSessionStoringProtocol> {
        self {
            AuthSessionStorage(keychain: self.keychainService())
        }.singleton
    }
    
    var authService: Factory<AuthServiceProtocol> {
        self {
            FirebaseAuthService(session: self.authSessionStorage())
        }.singleton
    }
    
    var passwordResetService: Factory<PasswordResetServiceProtocol> {
        self {
            FirebasePasswordResetService()
        }.singleton
    }
    
    // MARK: - Security
    
    var keychainService: Factory<KeychainServiceProtocol> {
        self {
            KeychainService()
        }.singleton
    }
    
    // MARK: - Profile
    
    var avatarStorageService: Factory<AvatarStorageServiceProtocol> {
        self {
            AvatarStorageService()
        }.singleton
    }
    
    // MARK: - Checkout
    
    var checkoutStorage: Factory<CheckoutStoringProtocol> {
        self {
            CheckoutStorage.shared
        }.singleton
    }
    
    // MARK: - Maps
    
    var addressSearchService: Factory<AddressSearchServiceProtocol> {
        self {
            AddressSearchService()
        }
    }
    
    var geocodingService: Factory<GeocodingServiceProtocol> {
        self {
            CLGeocodingService()
        }
    }
    
    // MARK: - Notifications
    
    var localNotificationService: Factory<LocalNotifyingProtocol> {
        self {
            LocalNotificationService.shared
        }.singleton
    }
    
    // MARK: - Debug
    
#if DEBUG
    var debugImportStorage: Factory<DebugImportStoringProtocol> {
        self {
            DebugImportStorage.shared
        }
    }
    
    var checksumStorage: ParameterFactory<String, ChecksumStoringProtocol> {
        self { namespace in
            ChecksumStorage(namespace: namespace)
        }
    }
    
    var debugImportService: Factory<DebugImportServicingProtocol> {
        self { [unowned self] in
            DebugImportService(
                checksumStoreFactory: { namespace in
                    self.checksumStorage(namespace)
                }
            )
        }.singleton
    }
    
    var debugImporter: Factory<DebugImportingProtocol> {
        self { [unowned self] in
            DebugImporter(
                debugImportService: self.debugImportService(),
                debugImportStorage: self.debugImportStorage()
            )
        }.singleton
    }
#endif
}
