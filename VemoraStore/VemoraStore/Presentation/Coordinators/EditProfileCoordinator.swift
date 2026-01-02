//
//  EditProfileCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import UIKit

/// Координатор `EditProfileCoordinator` управляет сценарием редактирования профиля пользователя.
///
/// Отвечает за:
/// - создание и отображение экрана `EditProfileViewController`;
/// - инициализацию `EditProfileViewModel` через `ViewModelBuildingProtocol`;
/// - навигацию к дочерним координаторам (`EditName`, `EditEmail`, `EditPhone`);
/// - обработку завершения сценария редактирования (`onFinish`).
///
/// Особенности:
/// - использует `CoordinatorBuildingProtocol` для создания зависимых координаторов;
/// - применяет `AuthServiceProtocol` для получения идентификатора текущего пользователя;
/// - скрывает нижний таббар при открытии экрана редактирования;
/// - управляет жизненным циклом дочерних координаторов, обеспечивая их корректное удаление после завершения.

final class EditProfileCoordinator: EditProfileCoordinatingProtocol {
    
    // MARK: - Deps
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    var onFinish: (() -> Void)?
    
    // MARK: - Factories
    
    private let viewModelFactory: ViewModelBuildingProtocol
    private let coordinatorFactory: CoordinatorBuildingProtocol
    private let authService: AuthServiceProtocol
    
    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        viewModelFactory: ViewModelBuildingProtocol,
        coordinatorFactory: CoordinatorBuildingProtocol,
        authService: AuthServiceProtocol
    ) {
        self.navigation = navigation
        self.viewModelFactory = viewModelFactory
        self.coordinatorFactory = coordinatorFactory
        self.authService = authService
    }
    
    // MARK: - Start
    
    func start() {
        let vm = viewModelFactory.makeEditProfileViewModel(
            userId: authService.currentUserId ?? ""
        )
        let vc = EditProfileViewController(viewModel: vm)
        vc.hidesBottomBarWhenPushed = true
        
        vc.onBack = { [weak self] in
            guard let self else { return }
            self.navigation.popViewController(animated: true)
            self.onFinish?()
        }
        
        vc.onEditName = { [weak self] in
            self?.showEditName()
        }
        vc.onEditEmail = { [weak self] in
            self?.showEditEmail()
        }
        vc.onEditPhone = { [weak self] in
            self?.showEditPhone()
        }
        
        navigation.pushViewController(vc, animated: true)
    }
    
    // MARK: - Private
    
    private func showEditName() {
        let editName = coordinatorFactory.makeEditNameCoordinator(
            navigation: navigation
        )
        add(editName)
        
        editName.onFinish = { [weak self, weak editName] in
            guard let self else { return }
            if let editName { self.remove(editName) }
        }
        
        editName.start()
    }
    
    private func showEditEmail() {
        let editEmail = coordinatorFactory.makeEditEmailCoordinator(
            navigation: navigation
        )
        add(editEmail)

        editEmail.onFinish = { [weak self, weak editEmail] in
            guard let self else { return }
            if let editEmail { self.remove(editEmail) }
        }

        editEmail.start()
    }
    
    private func showEditPhone() {
        let editPhone = coordinatorFactory.makeEditPhoneCoordinator(navigation: navigation)
        add(editPhone)

        editPhone.onFinish = { [weak self, weak editPhone] in
            guard let self else { return }
            if let editPhone { self.remove(editPhone) }
        }

        editPhone.start()
    }

    private func openStub(title: String) {
        let stub = UIViewController()
        stub.view.backgroundColor = .systemBackground
        stub.title = title
        stub.hidesBottomBarWhenPushed = true
        navigation.pushViewController(stub, animated: true)
    }
}
