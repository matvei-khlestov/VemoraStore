//
//  EditProfileCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import UIKit

final class EditProfileCoordinator: EditProfileCoordinatingProtocol {
    
    // MARK: - Deps
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    var onFinish: (() -> Void)?
    
    // MARK: - Factories
    
    private let viewModelFactory: ViewModelBuildingProtocol
    private let coordinatorFactory: CoordinatorBuildingProtocol
    
    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        viewModelFactory: ViewModelBuildingProtocol,
        coordinatorFactory: CoordinatorBuildingProtocol
    ) {
        self.navigation = navigation
        self.viewModelFactory = viewModelFactory
        self.coordinatorFactory = coordinatorFactory
    }
    
    // MARK: - Start
    
    func start() {
        let vm = viewModelFactory.makeEditProfileViewModel()
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
            self?.openStub(title: "Изменить телефон")
        }
        
        navigation.pushViewController(vc, animated: true)
    }
    
    // MARK: - Private
    
    private func showEditName() {
        let editName = coordinatorFactory.makeEditNameCoordinator(navigation: navigation)
        add(editName)
        
        editName.onFinish = { [weak self, weak editName] in
            guard let self else { return }
            if let editName { self.remove(editName) }
        }
        
        editName.start()
    }
    
    private func showEditEmail() {
        let editEmail = coordinatorFactory.makeEditEmailCoordinator(navigation: navigation)
        add(editEmail)

        editEmail.onFinish = { [weak self, weak editEmail] in
            guard let self else { return }
            if let editEmail { self.remove(editEmail) }
        }

        editEmail.start()
    }

    private func openStub(title: String) {
        let stub = UIViewController()
        stub.view.backgroundColor = .systemBackground
        stub.title = title
        stub.hidesBottomBarWhenPushed = true
        navigation.pushViewController(stub, animated: true)
    }
}
