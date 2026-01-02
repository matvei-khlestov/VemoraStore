//
//  CoordinatorBuildingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import UIKit

/// Протокол `CoordinatorBuildingProtocol`
///
/// Используется как **единая фабрика координаторов** приложения.
///
/// Основные задачи:
/// - централизованное создание координаторов для всех модулей (`Auth`, `Catalog`, `Profile`, `Checkout` и др.);
/// - инкапсуляция зависимостей, чтобы каждый координатор получал нужные сервисы при создании;
/// - упрощение unit- и UI-тестирования, позволяя подменять фабрику мок-реализацией.
///
/// Применяется:
/// - в `AppCoordinator` для сборки основных flow приложения;
/// - в отдельных координаторах для вложенной навигации;
/// - при UI-тестах для воссоздания маршрутов без ручного связывания зависимостей.

protocol CoordinatorBuildingProtocol {
    
    // MARK: - Catalog
    
    /// Создаёт координатор каталога.
    func makeCatalogCoordinator(
        navigation: UINavigationController
    ) -> CatalogCoordinatingProtocol
    
    // MARK: - Product Details
    
    /// Создаёт координатор экрана деталей товара.
    func makeProductDetailsCoordinator(
        navigation: UINavigationController,
        productId: String
    ) -> ProductDetailsCoordinatingProtocol

    // MARK: - Category Products

    /// Создаёт координатор экрана списка товаров категории.
    func makeCategoryProductsCoordinator(
        navigation: UINavigationController,
        categoryId: String,
        categoryTitle: String
    ) -> CategoryProductsCoordinatingProtocol

    // MARK: - Catalog Filter
    
    /// Создаёт координатор фильтров каталога.
    func makeCatalogFilterCoordinator(
        navigation: UINavigationController,
        initialState: FilterState
    ) -> CatalogFilterCoordinatingProtocol
    
    // MARK: - Map Picker
    
    /// Создаёт координатор выбора адреса на карте.
    func makeMapPickerCoordinator(
        navigation: UINavigationController
    ) -> MapPickerCoordinatingProtocol
    
    // MARK: - Checkout
    
    /// Создаёт координатор оформления заказа.
    func makeCheckoutCoordinator(
        navigation: UINavigationController
    ) -> CheckoutCoordinatingProtocol
    
    // MARK: - Order Success
    
    /// Создаёт координатор экрана успешного оформления заказа.
    func makeOrderSuccessCoordinator(
        navigation: UINavigationController
    ) -> OrderSuccessCoordinatingProtocol
    
    // MARK: - Favorites
    
    /// Создаёт координатор экрана избранного.
    func makeFavoritesCoordinator(
        navigation: UINavigationController
    ) -> FavoritesCoordinatingProtocol
    
    // MARK: - About
    
    /// Создаёт координатор экрана "О приложении".
    func makeAboutCoordinator(
        navigation: UINavigationController
    ) -> AboutCoordinatingProtocol
    
    // MARK: - Privacy Policy
    
    /// Создаёт координатор экрана политики конфиденциальности.
    func makePrivacyPolicyCoordinator(
        navigation: UINavigationController
    ) -> PrivacyPolicyCoordinatingProtocol
    
    // MARK: - Contact Us
    
    /// Создаёт координатор экрана обратной связи.
    func makeContactUsCoordinator(
        navigation: UINavigationController
    ) -> ContactUsCoordinatingProtocol
    
    // MARK: - Reset Password
    
    /// Создаёт координатор сброса пароля.
    func makeResetPasswordCoordinator(
        navigation: UINavigationController
    ) -> ResetPasswordCoordinatingProtocol
    
    // MARK: - Auth
    
    /// Создаёт координатор авторизации.
    func makeAuthCoordinator(
        navigation: UINavigationController
    ) -> AuthCoordinatingProtocol
    
    // MARK: - Profile Guest
    
    /// Создаёт координатор профиля гостя.
    func makeProfileGuestCoordinator(
        navigation: UINavigationController
    ) -> ProfileGuestCoordinatingProtocol
    
    // MARK: - Profile User
    
    /// Создаёт координатор профиля авторизованного пользователя.
    func makeProfileUserCoordinator(
        navigation: UINavigationController
    ) -> ProfileUserCoordinatingProtocol
    
    // MARK: - Orders
    
    /// Создаёт координатор истории заказов.
    func makeOrdersCoordinator(
        navigation: UINavigationController
    ) -> OrdersCoordinatingProtocol
    
    // MARK: - Cart
    
    /// Создаёт координатор корзины.
    func makeCartCoordinator(
        navigation: UINavigationController
    ) -> CartCoordinatingProtocol

    // MARK: - Edit Profile
    
    /// Создаёт координатор редактирования профиля.
    func makeEditProfileCoordinator(
        navigation: UINavigationController
    ) -> EditProfileCoordinatingProtocol

    // MARK: - Edit Name
    
    /// Создаёт координатор изменения имени пользователя.
    func makeEditNameCoordinator(
        navigation: UINavigationController
    ) -> EditNameCoordinatingProtocol

    // MARK: - Edit Email
    
    /// Создаёт координатор изменения email.
    func makeEditEmailCoordinator(
        navigation: UINavigationController
    ) -> EditEmailCoordinatingProtocol

    // MARK: - Edit Phone
    
    /// Создаёт координатор изменения телефона.
    func makeEditPhoneCoordinator(
        navigation: UINavigationController
    ) -> EditPhoneCoordinatingProtocol

    // MARK: - Main

    /// Создаёт главный координатор (`MainCoordinator`).
    func makeMainCoordinator(
        navigation: UINavigationController
    ) -> MainCoordinatingProtocol

    // MARK: - App

    /// Создаёт корневой координатор приложения (`AppCoordinator`).
    func makeAppCoordinator(
        navigation: UINavigationController
    ) -> AppCoordinatingProtocol
    
    // MARK: - Debug
    
#if DEBUG
    /// Создаёт координатор отладочного модуля.
    func makeDebugCoordinator(
        navigation: UINavigationController
    ) -> DebugCoordinatingProtocol
#endif
}
