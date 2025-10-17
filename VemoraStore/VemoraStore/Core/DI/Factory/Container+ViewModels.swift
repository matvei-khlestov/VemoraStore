//
//  Container+ViewModels.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import FactoryKit

/// Расширение `Container+ViewModels` — регистрация всех ViewModel приложения
/// в DI-контейнере.
///
/// Назначение:
/// - Определяет фабрики для всех ViewModel, используемых в слоях Presentation;
/// - Обеспечивает инъекцию зависимостей (`Repository`, `Service`, `Formatter`, `Validator`);
/// - Гарантирует корректное связывание ViewModel с данными пользователя (`userId`)
///   и контекстом навигации.
///
/// Особенности:
/// - Используется `FactoryKit` с типами `Factory` и `ParameterFactory`:
///   - `Factory` — для ViewModel без параметров;
///   - `ParameterFactory` — для ViewModel, где требуется `userId`, `productId`,
///     `categoryId` и т.п.;
/// - Поддерживает модульность и масштабируемость приложения;
/// - Позволяет переиспользовать зависимости между ViewModel без дублирования кода.
///
/// Основные группы ViewModel:
///
/// **Аутентификация**
/// - `signUpViewModel`, `signInViewModel`, `passwordResetViewModel` —
///   регистрация, вход и восстановление пароля.
///
/// **Каталог и товары**
/// - `catalogViewModel` — отображение каталога;
/// - `categoryProductsViewModel` — список товаров по категории;
/// - `productDetailsViewModel` — детали товара;
/// - `catalogFilterViewModel` — фильтрация товаров.
///
/// **Избранное и корзина**
/// - `favoritesViewModel` — управление избранным;
/// - `cartViewModel` — управление корзиной.
///
/// **Профиль и редактирование**
/// - `profileUserViewModel` — профиль пользователя;
/// - `editProfileViewModel` — редактирование профиля;
/// - `editNameViewModel`, `editEmailViewModel`, `editPhoneViewModel` —
///   изменение данных пользователя.
///
/// **Оформление заказа**
/// - `checkoutViewModel` — оформление покупки;
/// - `ordersViewModel` — список заказов.
///
/// **Адреса и доставка**
/// - `deliveryDetailsViewModel` — детали доставки;
/// - `addressConfirmSheetViewModel` — подтверждение адреса;
/// - `mapPickerViewModel` — выбор адреса на карте.
///
/// **UI-компоненты ввода**
/// - `phoneInputSheetViewModel` — ввод телефона;
/// - `commentInputSheetViewModel` — ввод комментария.
///
/// **Отладка (DEBUG)**
/// - `debugImportViewModel` — импорт данных для тестовой среды.
///
/// Расширение входит в модуль **Dependency Injection Layer (ViewModels)**
/// и обеспечивает слой Presentation необходимыми зависимостями для ViewModel.

extension Container {
    
    // MARK: - Auth
    
    var signUpViewModel: Factory<SignUpViewModelProtocol> {
        self {
            SignUpViewModel(
                auth: self.authService(),
                validator: self.formValidator(),
                makeProfileRepository: { uid in
                    self.profileRepository(uid)
                }
            )
        }
    }
    
    var signInViewModel: Factory<SignInViewModelProtocol> {
        self {
            SignInViewModel(
                auth: self.authService(),
                validator: self.formValidator()
            )
        }
    }
    
    var passwordResetViewModel: Factory<ResetPasswordViewModelProtocol> {
        self {
            ResetPasswordViewModel(
                service: self.passwordResetService(),
                validator: self.formValidator()
            )
        }
    }
    
    // MARK: - Catalog
    
    var catalogViewModel: ParameterFactory<String, CatalogViewModelProtocol> {
        self { userId in
            CatalogViewModel(
                repository: self.catalogRepository(),
                cartRepository: self.cartRepository(userId),
                favoritesRepository: self.favoritesRepository(userId),
                priceFormatter: self.priceFormatter()
            )
        }
    }
    
    var catalogFilterViewModel: Factory<CatalogFilterViewModelProtocol> {
        self {
            CatalogFilterViewModel(
                repository: self.catalogRepository()
            )
        }
    }
    
    var productDetailsViewModel: ParameterFactory<(String, String),
                                                    ProductDetailsViewModelProtocol> {
        self { (productId, userId) in
            ProductDetailsViewModel(
                productId: productId,
                favoritesRepository: self.favoritesRepository(userId),
                cartRepository: self.cartRepository(userId),
                catalogRepository: self.catalogRepository(),
                priceFormatter: self.priceFormatter()
            )
        }
    }
    
    var categoryProductsViewModel: ParameterFactory<(String, String),
                                                    CategoryProductsViewModelProtocol> {
        self { (categoryId, userId) in
            CategoryProductsViewModel(
                repository: self.catalogRepository(),
                cartRepository: self.cartRepository(userId),
                favoritesRepository: self.favoritesRepository(userId),
                priceFormatter: self.priceFormatter(),
                categoryId: categoryId
            )
        }
    }
    
    // MARK: - Favorites
    
    var favoritesViewModel: ParameterFactory<String, FavoritesViewModelProtocol> {
        self { userId in
            FavoritesViewModel(
                favoritesRepository: self.favoritesRepository(userId),
                cartRepository: self.cartRepository(userId),
                priceFormatter: self.priceFormatter(),
                notifier: self.localNotificationService()
            )
        }
    }
    
    // MARK: - Cart
    
    var cartViewModel: ParameterFactory<String, CartViewModelProtocol> {
        self { userId in
            CartViewModel(
                cartRepository: self.cartRepository(userId),
                priceFormatter: self.priceFormatter(),
                notifier: self.localNotificationService()
            )
        }
    }
    
    // MARK: - Profile
    
    var profileUserViewModel: ParameterFactory<String, ProfileUserViewModelProtocol> {
        self { uid in
            ProfileUserViewModel(
                auth: self.authService(),
                avatarStorage: self.avatarStorageService(),
                profileRepository: self.profileRepository(uid),
                userId: uid
            )
        }
    }
    
    var editProfileViewModel: ParameterFactory<String, EditProfileViewModelProtocol> {
        self { userId in
            EditProfileViewModel(
                avatarStorage: self.avatarStorageService(),
                profileRepository: self.profileRepository(userId),
                userId: userId,
                checkoutStorage: self.checkoutStorage()
            )
        }
    }
    
    var editNameViewModel: ParameterFactory<String, EditNameViewModelProtocol> {
        self { uid in
            EditNameViewModel(
                profileRepository: self.profileRepository(uid),
                userId: uid,
                validator: self.formValidator()
            )
        }
    }
    
    var editEmailViewModel: ParameterFactory<String, EditEmailViewModelProtocol> {
        self { userId in
            EditEmailViewModel(
                profileRepository: self.profileRepository(userId),
                validator: self.formValidator(),
                userId: userId,
            )
        }
    }
    
    var editPhoneViewModel: ParameterFactory<String, EditPhoneViewModelProtocol> {
        self { userId in
            EditPhoneViewModel(
                profileRepository: self.profileRepository(userId),
                validator: self.formValidator(),
                userId: userId,
                checkoutStorage: self.checkoutStorage()
            )
        }
    }
    
    // MARK: - Checkout
    
    var checkoutViewModel: ParameterFactory<(String, [CartItem]),
                                            CheckoutViewModelProtocol> {
        self { (userId, snapshotItems) in
            CheckoutViewModel(
                cartRepository: self.cartRepository(userId),
                ordersRepository: self.ordersRepository(userId),
                phoneFormatter: self.phoneFormatter(),
                priceFormatter: self.priceFormatter(),
                snapshotItems: snapshotItems,
                storage: self.checkoutStorage(),
                currentUserId: userId,
                notifier: self.localNotificationService()
            )
        }
    }
    
    // MARK: - Orders
    
    var ordersViewModel: ParameterFactory<String, OrdersViewModelProtocol> {
        self { userId in
            OrdersViewModel(
                repository: self.ordersRepository(userId),
                priceFormatter: self.priceFormatter()
            )
        }
    }
    
    // MARK: - Address / Delivery
    
    var deliveryDetailsViewModel: ParameterFactory<String, DeliveryDetailsViewModelProtocol> {
        self { baseAddress in
            DeliveryDetailsViewModel(
                baseAddress: baseAddress,
                formatter: self.deliveryAddressFormatter()
            )
        }
    }
    
    // MARK: - Address Confirm
    
    var addressConfirmSheetViewModel: Factory<AddressConfirmSheetViewModelProtocol> {
        self {
            AddressConfirmSheetViewModel(
                search: self.addressSearchService(),
                formatter: self.addressFormatter()
            )
        }
    }
    
    // MARK: - Phone Input
    
    var phoneInputSheetViewModel: ParameterFactory<String?, PhoneInputSheetViewModelProtocol> {
        self { initialPhone in
            PhoneInputSheetViewModel(
                initialPhone: initialPhone,
                validator: self.formValidator()
            )
        }
    }
    
    // MARK: - Comment Input
    
    var commentInputSheetViewModel: ParameterFactory<String?, CommentInputSheetViewModelProtocol> {
        self { initialComment in
            CommentInputSheetViewModel(
                initialComment: initialComment,
                validator: self.formValidator()
            )
        }
    }
    
    // MARK: - Map Picker
    
    var mapPickerViewModel: Factory<MapPickerViewModelProtocol> {
        self {
            MapPickerViewModel(
                geocoder: self.geocodingService(),
                formatter: self.addressFormatter()
            )
        }
    }
    
    // MARK: - Debug
    
#if DEBUG
    var debugImportViewModel: Factory<DebugImportViewModelProtocol> {
        self {
            DebugImportViewModel(
                debugImportStorage: self.debugImportStorage(),
                debugImporter: self.debugImporter()
            )
        }
    }
#endif
}
