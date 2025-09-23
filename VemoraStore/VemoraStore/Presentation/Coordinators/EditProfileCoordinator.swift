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
    
    private let viewModelFactory: ViewModelBuildingProtocol
    
    // MARK: - Init
    
    init(
        navigation: UINavigationController,
        viewModelFactory: ViewModelBuildingProtocol
    ) {
        self.navigation = navigation
        self.viewModelFactory = viewModelFactory
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
        
        // Заглушки на экраны редактирования
        vc.onEditName = { [weak self] in self?.openStub(title: "Изменить имя") }
        vc.onEditEmail = { [weak self] in self?.openStub(title: "Изменить почту") }
        vc.onEditPhone = { [weak self] in self?.openStub(title: "Изменить телефон") }
        
        navigation.pushViewController(vc, animated: true)
    }
    
    // MARK: - Helpers
    
    private func openStub(title: String) {
        let stub = UIViewController()
        stub.view.backgroundColor = .systemBackground
        stub.title = title
        stub.hidesBottomBarWhenPushed = true
        navigation.pushViewController(stub, animated: true)
    }
}
