//
//  ViewModelFactory.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import Foundation
import FactoryKit

/// Класс `ViewModelFactory`
///
/// Реализует протокол `ViewModelBuildingProtocol` и отвечает за создание всех ViewModel в приложении.
/// Использует механизм внедрения зависимостей через `FactoryKit.Container`, обеспечивая гибкость
/// конфигурации и тестируемость.
///
/// Основные задачи:
/// - создание экземпляров всех ViewModel модулей приложения;
/// - централизованное управление зависимостями;
/// - переиспользование общих зависимостей через DI-контейнер.
///
/// Используется координаторами и экранными фабриками (`CoordinatorFactory`, `ScreenFactory`)
/// для инициализации ViewModel при сборке модулей.

final class ViewModelFactory: ViewModelBuildingProtocol {
    
    private let container: Container
    
    init(container: Container) {
        self.container = container
    }
    
    // MARK: - Auth
    
    func makeSignUpViewModel() -> SignUpViewModelProtocol {
        container.signUpViewModel()
    }
    
    func makeSignInViewModel() -> SignInViewModelProtocol {
        container.signInViewModel()
    }
    
    func makeResetPasswordViewModel() -> ResetPasswordViewModelProtocol {
        container.passwordResetViewModel()
    }
    
    // MARK: - Catalog
    
    func makeCatalogViewModel(userId: String) -> CatalogViewModelProtocol {
        container.catalogViewModel(userId)
    }
    
    func makeCatalogFilterViewModel() -> CatalogFilterViewModelProtocol {
        container.catalogFilterViewModel()
    }
    
    func makeProductDetailsViewModel(productId: String, userId: String) -> ProductDetailsViewModelProtocol {
        container.productDetailsViewModel((productId, userId))
    }

    func makeCategoryProductsViewModel(categoryId: String, userId: String) -> CategoryProductsViewModelProtocol {
        container.categoryProductsViewModel((categoryId, userId))
    }
    
    // MARK: - Favorites
    
    func makeFavoritesViewModel(userId: String) -> FavoritesViewModelProtocol {
        container.favoritesViewModel(userId)
    }
    
    // MARK: - Cart
    
    func makeCartViewModel(userId: String) -> CartViewModelProtocol {
        container.cartViewModel(userId)
    }
    
    // MARK: - Profile
    
    func makeProfileUserViewModel(uid: String) -> ProfileUserViewModelProtocol {
        container.profileUserViewModel(uid)
    }
    
    func makeEditProfileViewModel(userId: String) -> EditProfileViewModelProtocol {
        container.editProfileViewModel(userId)
    }
    
    func makeEditNameViewModel(uid: String) -> EditNameViewModelProtocol {
        container.editNameViewModel(uid)
    }
    
    func makeEditEmailViewModel(userId: String) -> EditEmailViewModelProtocol {
        container.editEmailViewModel(userId)
    }
    
    func makeEditPhoneViewModel(userId: String) -> EditPhoneViewModelProtocol {
        container.editPhoneViewModel(userId)
    }
    
    // MARK: - Checkout
    
    func makeCheckoutViewModel(
        userId: String,
        snapshotItems: [CartItem]
    ) -> CheckoutViewModelProtocol {
        container.checkoutViewModel((userId, snapshotItems))
    }
    
    // MARK: - Orders
    
    func makeOrdersViewModel(userId: String) -> OrdersViewModelProtocol {
        container.ordersViewModel(userId)
    }
    
    // MARK: - Address / Delivery
    
    func makeDeliveryDetailsViewModel(baseAddress: String) -> DeliveryDetailsViewModelProtocol {
        container.deliveryDetailsViewModel(baseAddress)
    }
    
    func makeAddressConfirmSheetViewModel() -> AddressConfirmSheetViewModelProtocol {
        container.addressConfirmSheetViewModel()
    }
    
    // MARK: - Phone Input
    
    func makePhoneInputSheetViewModel(initialPhone: String? = nil) -> PhoneInputSheetViewModelProtocol {
        container.phoneInputSheetViewModel(initialPhone)
    }
    
    // MARK: - Comment Input
    
    func makeCommentInputSheetViewModel(initialComment: String? = nil) -> CommentInputSheetViewModelProtocol {
        container.commentInputSheetViewModel(initialComment)
    }
    
    // MARK: - Map Picker
    
    func makeMapPickerViewModel() -> MapPickerViewModelProtocol {
        container.mapPickerViewModel()
    }
}
