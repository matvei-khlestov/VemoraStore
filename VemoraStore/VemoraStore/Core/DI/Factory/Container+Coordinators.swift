//
//  Container+Coordinators.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import Foundation
import FactoryKit
import UIKit

/// Расширение `Container+Coordinators` — регистрация всех координаторов
/// приложения в DI-контейнере.
///
/// Назначение:
/// - Определяет фабрики для всех координаторов, управляющих навигацией между модулями;
/// - Инкапсулирует создание координаторов через `ParameterFactory`,
///   передавая зависимости (`navigation`, `viewModelFactory`, `authService` и др.);
/// - Позволяет централизованно управлять навигацией приложения через `CoordinatorFactory`.
///
/// Особенности:
/// - Каждый координатор зарегистрирован как `ParameterFactory`,
///   что позволяет передавать параметры при создании (например, `productId`,
///   `categoryId`, `FilterState`);
/// - Используется `FactoryKit` для декларативного описания зависимостей;
/// - Координаторы связаны между собой через `CoordinatorBuildingProtocol`,
///   реализуя композицию навигации.
///
/// Основные группы координаторов:
///
/// **Каталог и товары**
/// - `catalogCoordinator` — главный каталог товаров;
/// - `categoryProductsCoordinator` — товары по категории;
/// - `productDetailsCoordinator` — экран деталей товара;
/// - `catalogFilterCoordinator` — фильтры каталога.
///
/// **Корзина и заказы**
/// - `cartCoordinator` — управление корзиной;
/// - `checkoutCoordinator` — оформление заказа;
/// - `orderSuccessCoordinator` — успешное завершение заказа;
/// - `ordersCoordinator` — список заказов.
///
/// **Профиль и настройки**
/// - `profileUserCoordinator` / `profileGuestCoordinator` — профиль пользователя / гостя;
/// - `editProfileCoordinator`, `editNameCoordinator`, `editEmailCoordinator`,
///   `editPhoneCoordinator` — редактирование данных профиля;
/// - `aboutCoordinator`, `privacyPolicyCoordinator`, `contactUsCoordinator` —
///   информационные экраны.
///
/// **Авторизация**
/// - `authCoordinator` — модуль аутентификации;
/// - `resetPasswordCoordinator` — восстановление пароля.
///
/// **Главная навигация**
/// - `mainCoordinator` — корневой таб-бар;
/// - `appCoordinator` — стартовый координатор приложения (root flow).
///
/// Расширение входит в модуль **Dependency Injection Layer (Coordinators)**
/// и обеспечивает слой Presentation навигацией через единый DI-контейнер.

extension Container {
    
    // MARK: - Catalog
    
    var catalogCoordinator: ParameterFactory<UINavigationController, CatalogCoordinatingProtocol> {
        self { navigation in
            CatalogCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory(),
                coordinatorFactory: self.coordinatorFactory(),
                authService: self.authService()
            )
        }
    }
    
    // MARK: - Product Details

    var productDetailsCoordinator: ParameterFactory<(UINavigationController, String), ProductDetailsCoordinatingProtocol> {
        self { navigation, productId in
            ProductDetailsCoordinator(
                navigation: navigation,
                productId: productId,
                viewModelFactory: self.viewModelFactory(),
                coordinatorFactory: self.coordinatorFactory(),
                authService: self.authService()
            )
        }
    }

    // MARK: - Category Products

    var categoryProductsCoordinator: ParameterFactory<(UINavigationController, String, String),
                                                      CategoryProductsCoordinatingProtocol> {
        self { navigation, categoryId, categoryTitle in
            CategoryProductsCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory(),
                coordinatorFactory: self.coordinatorFactory(),
                authService: self.authService(),
                categoryId: categoryId,
                categoryTitle: categoryTitle
            )
        }
    }

    // MARK: - Catalog Filter

    var catalogFilterCoordinator: ParameterFactory<(UINavigationController, FilterState), CatalogFilterCoordinatingProtocol> {
        self { navigation, initialState in
            CatalogFilterCoordinator(
                navigation: navigation,
                initialState: initialState,
                viewModelFactory: self.viewModelFactory()
            )
        }
    }
    
    // MARK: - Map Picker
    
    var mapPickerCoordinator: ParameterFactory<UINavigationController,
                                               MapPickerCoordinatingProtocol> {
        self { nav in
            MapPickerCoordinator(
                navigation: nav,
                viewModelFactory: self.viewModelFactory()
            )
        }
    }
    
    // MARK: - Checkout
    
    var checkoutCoordinator: ParameterFactory<UINavigationController, CheckoutCoordinatingProtocol> {
        self { navigation in
            CheckoutCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory(),
                coordinatorFactory: self.coordinatorFactory(),
                phoneFormatter: self.phoneFormatter(),
                sessionManager: self.sessionManager(),
                authService: self.authService()
            )
        }
    }
    
    // MARK: - Order Success
    
    var orderSuccessCoordinator: ParameterFactory<UINavigationController, OrderSuccessCoordinatingProtocol> {
        self { navigation in
            OrderSuccessCoordinator(
                navigation: navigation,
                coordinatorFactory: self.coordinatorFactory()
            )
        }
    }
    
    // MARK: - Favorites
    
    var favoritesCoordinator: ParameterFactory<UINavigationController, FavoritesCoordinatingProtocol> {
        self { navigation in
            FavoritesCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory(),
                coordinatorFactory: self.coordinatorFactory(),
                authService: self.authService()
            )
        }
    }
    
    // MARK: - Cart
    
    var cartCoordinator: ParameterFactory<UINavigationController, CartCoordinatingProtocol> {
        self { navigation in
            CartCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory(),
                coordinatorFactory: self.coordinatorFactory(),
                authService: self.authService()
            )
        }
    }
    
    // MARK: - Orders
    
    var ordersCoordinator: ParameterFactory<UINavigationController, OrdersCoordinatingProtocol> {
        self { navigation in
            OrdersCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory(),
                authService: self.authService()
            )
        }
    }
    
    // MARK: - About
    
    var aboutCoordinator: ParameterFactory<UINavigationController, AboutCoordinatingProtocol> {
        self { navigation in
            AboutCoordinator(navigation: navigation)
        }
    }
    
    // MARK: - Privacy Policy
    
    var privacyPolicyCoordinator: ParameterFactory<UINavigationController, PrivacyPolicyCoordinatingProtocol> {
        self { navigation in
            PrivacyPolicyCoordinator(navigation: navigation)
        }
    }
    
    // MARK: - Contact Us
    
    var contactUsCoordinator: ParameterFactory<UINavigationController, ContactUsCoordinatingProtocol> {
        self { navigation in
            ContactUsCoordinator(navigation: navigation)
        }
    }
    
    // MARK: - Reset Password
    
    var resetPasswordCoordinator: ParameterFactory<UINavigationController, ResetPasswordCoordinatingProtocol> {
        self { navigation in
            ResetPasswordCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory()
            )
        }
    }
    
    // MARK: - Auth
    
    var authCoordinator: ParameterFactory<UINavigationController, AuthCoordinatingProtocol> {
        self { navigation in
            AuthCoordinator(
                navigation: navigation,
                authService: self.authService(),
                viewModelFactory: self.viewModelFactory(),
                coordinatorFactory: self.coordinatorFactory()
            )
        }
    }
    
    // MARK: - Profile Guest
    
    var profileGuestCoordinator: ParameterFactory<UINavigationController, ProfileGuestCoordinatingProtocol> {
        self { navigation in
            ProfileGuestCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory(),
                coordinatorFactory: self.coordinatorFactory()
            )
        }
    }
    
    // MARK: - Profile User
    
    var profileUserCoordinator: ParameterFactory<UINavigationController, ProfileUserCoordinatingProtocol> {
        self { navigation in
            ProfileUserCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory(),
                coordinatorFactory: self.coordinatorFactory(),
                authService: self.authService()
            )
        }
    }
    
    // MARK: - Edit Profile
    
    var editProfileCoordinator: ParameterFactory<UINavigationController, EditProfileCoordinatingProtocol> {
        self { navigation in
            EditProfileCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory(),
                coordinatorFactory: self.coordinatorFactory(),
                authService: self.authService()
            )
        }
    }
    
    // MARK: - Edit Name
    
    var editNameCoordinator: ParameterFactory<UINavigationController, EditNameCoordinatingProtocol> {
        self { navigation in
            EditNameCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory(),
                authService: self.authService()
            )
        }
    }
    
    // MARK: - Edit Email
    
    var editEmailCoordinator: ParameterFactory<UINavigationController, EditEmailCoordinatingProtocol> {
        self { navigation in
            EditEmailCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory(),
                authService: self.authService()
            )
        }
    }
    
    // MARK: - Edit Phone
    
    var editPhoneCoordinator: ParameterFactory<UINavigationController, EditPhoneCoordinatingProtocol> {
        self { navigation in
            EditPhoneCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory(),
                phoneFormatter: self.phoneFormatter(),
                authService: self.authService()
            )
        }
    }
    
    // MARK: - Main
    
    var mainCoordinator: ParameterFactory<UINavigationController, MainCoordinatingProtocol> {
        self { navigation in
            MainCoordinator(
                navigation: navigation,
                viewModelFactory: self.viewModelFactory(),
                coordinatorFactory: self.coordinatorFactory()
            )
        }
    }
    
    // MARK: - App
    
    var appCoordinator: ParameterFactory<UINavigationController, AppCoordinatingProtocol> {
        self { navigation in
            AppCoordinator(
                navigation: navigation,
                authService: self.authService(),
                coordinatorFactory: self.coordinatorFactory(),
                sessionManager: self.sessionManager()
            )
        }
    }
}
