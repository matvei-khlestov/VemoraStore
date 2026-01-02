//
//  Container+Utils.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import FactoryKit

/// Расширение `Container+Utils` — регистрация вспомогательных форматтеров и валидаторов
/// в DI-контейнере приложения.
///
/// Назначение:
/// - Обеспечивает доступ к утилитарным зависимостям, используемым во ViewModel, сервисах и UI;
/// - Позволяет централизованно управлять экземплярами форматтеров и валидаторов;
/// - Реализовано с использованием `FactoryKit` для автоматического внедрения зависимостей.
///
/// Состав зарегистрированных фабрик:
/// - `addressFormatter`: форматирует адреса (город, улица, дом);
/// - `deliveryAddressFormatter`: форматирует адрес доставки для UI и отображения в заказах;
/// - `formValidator`: выполняет валидацию форм (email, пароль, поля ввода);
/// - `phoneFormatter`: форматирует телефонные номера в локальный или международный формат;
/// - `priceFormatter`: форматирует цены с учетом валюты и локали.
///
/// Особенности:
/// - Все зависимости создаются как *transient*-фабрики (новый экземпляр при каждом вызове);
/// - Используются лёгкие протоколы (`FormattingProtocol`, `ValidatingProtocol`) для тестируемости;
/// - Сервисы из этого расширения активно применяются в слоях **Presentation** и **Domain**.
///
/// Расширение входит в модуль **Dependency Injection Layer (Utils)**
/// и обеспечивает доступ к сервисам форматирования и валидации в рамках приложения.

extension Container {
    
    var addressFormatter: Factory<AddressFormattingProtocol> {
        self {
            DefaultAddressFormatter()
        }
    }
    
    var deliveryAddressFormatter: Factory<DeliveryAddressFormattingProtocol> {
        self {
            DefaultDeliveryAddressFormatter()
        }
    }
    
    var formValidator: Factory<FormValidatingProtocol> {
        self {
            FormValidator()
        }
    }
    
    var phoneFormatter: Factory<PhoneFormattingProtocol> {
        self {
            PhoneFormatter()
        }
    }
    
    var priceFormatter: Factory<PriceFormattingProtocol> {
        self {
            PriceFormatter()
        }
    }
}
