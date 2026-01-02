//
//  ViewModelBuildingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 22.09.2025.
//

import Foundation


/// Протокол `ViewModelBuildingProtocol`
///
/// Используется как **единая фабрика ViewModel’ей** для всех экранов приложения.
///
/// Основные задачи:
/// - создание экземпляров ViewModel с внедрением необходимых зависимостей (DI);
/// - инкапсуляция логики сборки, чтобы координаторы и контроллеры не создавали ViewModel напрямую;
/// - обеспечение единообразия конфигурации при UI- и интеграционных тестах.
///
/// Применяется:
/// - в координаторах (`AuthCoordinator`, `CatalogCoordinator`, `ProfileCoordinator` и др.);
/// - при написании UI-тестов для сборки ViewModel без реальных сервисов.

protocol ViewModelBuildingProtocol {
    
    // MARK: - Auth
    
    /// Создаёт ViewModel для экрана регистрации.
    func makeSignUpViewModel() -> SignUpViewModelProtocol
    
    /// Создаёт ViewModel для экрана входа.
    func makeSignInViewModel() -> SignInViewModelProtocol
    
    /// Создаёт ViewModel для экрана сброса пароля.
    func makeResetPasswordViewModel() -> ResetPasswordViewModelProtocol
    
    // MARK: - Catalog
    
    /// Создаёт ViewModel для каталога.
    func makeCatalogViewModel(userId: String) -> CatalogViewModelProtocol
    
    /// Создаёт ViewModel для фильтров каталога.
    func makeCatalogFilterViewModel() -> CatalogFilterViewModelProtocol
    
    /// Создаёт ViewModel для деталей продукта.
    func makeProductDetailsViewModel(
        productId: String,
        userId: String
    ) -> ProductDetailsViewModelProtocol
    
    /// Создаёт ViewModel для списка товаров категории.
    func makeCategoryProductsViewModel(
        categoryId: String,
        userId: String
    ) -> CategoryProductsViewModelProtocol
    
    // MARK: - Favorites
    
    /// Создаёт ViewModel для экрана избранного.
    func makeFavoritesViewModel(userId: String) -> FavoritesViewModelProtocol
    
    // MARK: - Cart
    
    /// Создаёт ViewModel для корзины.
    func makeCartViewModel(userId: String) -> CartViewModelProtocol
    
    // MARK: - Profile
    
    /// Создаёт ViewModel профиля пользователя.
    func makeProfileUserViewModel(uid: String) -> ProfileUserViewModelProtocol
    
    /// Создаёт ViewModel для редактирования профиля.
    func makeEditProfileViewModel(userId: String) -> EditProfileViewModelProtocol
    
    /// Создаёт ViewModel для изменения имени.
    func makeEditNameViewModel(uid: String) -> EditNameViewModelProtocol
    
    /// Создаёт ViewModel для изменения email.
    func makeEditEmailViewModel(userId: String) -> EditEmailViewModelProtocol
    
    /// Создаёт ViewModel для изменения телефона.
    func makeEditPhoneViewModel(userId: String) -> EditPhoneViewModelProtocol
    
    // MARK: - Checkout
    
    /// Создаёт ViewModel для оформления заказа.
    func makeCheckoutViewModel(
        userId: String,
        snapshotItems: [CartItem]
    ) -> CheckoutViewModelProtocol
    
    // MARK: - Orders
    
    /// Создаёт ViewModel для истории заказов.
    func makeOrdersViewModel(userId: String) -> OrdersViewModelProtocol
    
    // MARK: - Delivery
    
    /// Создаёт ViewModel для деталей адреса доставки.
    func makeDeliveryDetailsViewModel(baseAddress: String) -> DeliveryDetailsViewModelProtocol
    
    /// Создаёт ViewModel для подтверждения адреса.
    func makeAddressConfirmSheetViewModel() -> AddressConfirmSheetViewModelProtocol
    
    // MARK: - Sheets
    
    /// Создаёт ViewModel для ввода номера телефона.
    func makePhoneInputSheetViewModel(initialPhone: String?) -> PhoneInputSheetViewModelProtocol
    
    /// Создаёт ViewModel для ввода комментария к заказу.
    func makeCommentInputSheetViewModel(initialComment: String?) -> CommentInputSheetViewModelProtocol
    
    // MARK: - Map Picker
    
    /// Создаёт ViewModel для выбора местоположения на карте.
    func makeMapPickerViewModel() -> MapPickerViewModelProtocol
    
    // MARK: - Debug
    
#if DEBUG
    /// Создаёт ViewModel для отладки импорта данных.
    func makeDebugImortViewModel() -> DebugImportViewModelProtocol
#endif
}
